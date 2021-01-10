import std/monotimes, strformat, math, strutils

proc nowMs(): float64 =
  getMonoTime().ticks.float64 / 1000000.0

proc total(s: seq[SomeNumber]): float =
  ## Computes total of a sequence.
  for v in s:
    result += v.float

proc min(s: seq[SomeNumber]): float =
  ## Computes mean (average) of a sequence.
  result = s[0].float
  for v in s[1 .. ^1]:
    result = min(v.float, result)

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

var
  shownHeader = false
  keepInt: int

template keep*(value: untyped) =
  keepInt = 0
  {.emit: [keepInt, "= (void*)&", value,";"].}
  #keepInt = cast[int](value)

proc dots(n: int): string =
  for i in 0 ..< n:
    result.add(".")

template timeIt*(tag: string, iterations: untyped, body: untyped) =
  ## Quick template to time an operation.
  if not shownHeader:
    shownHeader = true
    echo "name ............................... min time      avg time    std dv   runs"

  var
    num = 0
    total: float64
    deltas: seq[float64]

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

      when iterations != 0:
        if num >= iterations:
          break
      else:
        if total > 5_000.0 or num >= 1000:
          break

  var minDelta = min(deltas)
  removeOutliers(deltas)

  var readout = ""
  var m = ""
  var s = ""
  var d = ""
  formatValue(m, minDelta, "0.3f")
  formatValue(s, mean(deltas) , "0.3f")
  formatValue(d, stdev(deltas) , "0.3f")
  readout = m & " ms " & align(s, 10) & " ms " & align("±" & d,10) & "  " & align("x" & $num, 5)

  echo tag, " ", dots(40 - tag.len - m.len), " ", readout

template timeIt*(tag: string, body: untyped) =
  timeIt(tag, 0, body)
