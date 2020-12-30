## Public interface to you library.

import std/monotimes, strformat, math, strutils

proc nowMs(): float64 =
  getMonoTime().ticks.float64 / 1000000.0

proc total(s: seq[SomeNumber]): float =
  ## Computes total of a sequence.
  for v in s:
    result += v.float

proc mean(s: seq[SomeNumber]): float =
  ## Computes mean (average) of a sequence.
  if s.len == 0: return NaN
  s.total / s.len.float

proc variance(s: seq[SomeNumber]): float =
  ## Computes the sample variance of a sequence.
  if s.len <= 1:
    return
  let a = s.mean()
  for v in s:
    result += (v.float - a) ^ 2
  result /= (s.len.float - 1)

proc stdev(s: seq[SomeNumber]): float =
  ## Computes the sample standard deviation of a sequence.
  sqrt(s.variance)

proc removeOutliers(s: var seq[SomeNumber]) =
  let avg = mean(s)
  let std = stdev(s)
  var i = 0
  while i < s.len:
    if abs(s[i] - avg) > std*2:
      #echo "remove: ", s[i]
      s.delete(i)
      continue
    inc i

var keepInt: int
template keep*(value: untyped) =
  keepInt = cast[int](value)

template timeIt*(tag: string, body: untyped) =
  ## Quick template to time an operation.

  var
    num = 0
    total: float64
    deltas: seq[float64]
    stdd: seq[float64]

  block:
    proc test() =
      body

    while true:
      inc num
      let start = nowMs()

      test()

      let finish = nowMs()

      let delta = finish - start
      total += delta
      deltas.add(delta)
      if total > 60_000.0:
        break
      stdd.add(stdev(deltas))
      if num >= 10:
        if mean(stdd[^9 .. ^1]) - mean(stdd[^5 .. ^1]) < 0.2:
          break

  removeOutliers(deltas)
  removeOutliers(deltas)

  var readout = ""
  var s = ""
  var d = ""
  formatValue(s, mean(deltas) , "0.3f")
  formatValue(d, stdev(deltas) , "0.3f")
  readout = s & " ms " & align("±" & d,10) & "  x" & $num

  var dots = ""
  for i in tag.len + s.len .. 40:
    dots.add(".")

  echo tag, " ", dots, " ", readout
