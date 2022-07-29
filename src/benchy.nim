import std/monotimes, strformat, math, strutils

when defined(benchyAffinty):
  when defined(windows):
    proc GetCurrentProcess(): int {.stdcall, dynlib: "kernel32", importc.}
    proc SetProcessAffinityMask(handle: int, mask: uint64): cint
      {.stdcall, dynlib: "kernel32", importc.}

    const REALTIME_PRIORITY_CLASS = 0x00000100
    proc SetPriorityClass(handle: int, class: uint32): cint
      {.stdcall, dynlib: "kernel32", importc.}

    discard SetProcessAffinityMask(
      GetCurrentProcess(),
      0b0000_0010
    )
    discard SetPriorityClass(
      GetCurrentProcess(),
      REALTIME_PRIORITY_CLASS
    )
  # TODO linux/mac

proc nowMs(): float64 =
  ## Gets current milliseconds.
  getMonoTime().ticks.float64 / 1000000.0

proc total(s: seq[float64]): float64 =
  ## Computes total of a sequence.
  for v in s:
    result += v.float

proc min(s: seq[float64]): float64 =
  ## Computes mean (average) of a sequence.
  result = s[0].float
  for i in 1..s.high:
    result = min(s[i].float, result)

proc mean(s: seq[float64]): float64 =
  ## Computes mean (average) of a sequence.
  if s.len == 0: return NaN
  s.total / s.len.float

proc median(s: seq[float64]): float64 =
  ## Gets median (middle number) of a sequence.
  if s.len == 0: return NaN
  s[s.len div 2]

proc variance(s: seq[float64]): float64 =
  ## Computes the sample variance of a sequence.
  if s.len <= 1:
    return
  let a = s.mean()
  for v in s:
    result += (v.float - a) ^ 2
  result /= (s.len.float - 1)

proc stdDev(s: seq[float64]): float64 =
  ## Computes the sample standard deviation of a sequence.
  sqrt(s.variance)

proc removeOutliers(s: var seq[float64], p = 3.0) =
  ## Remove numbers that are above p standard deviation.
  let avg = mean(s)
  let std = stdDev(s)
  var i = 0
  while i < s.len:
    if abs(s[i] - avg) > std * p:
      s.delete(i)
    else:
      inc i

proc perBetween(s: seq[float64], a, b: float64): float64 =
  var count: int
  for n in s:
    if n >= a and n < b:
      inc count
  return count.float / s.len.float

const brailleArr = [
  ["⠀", "⢀", "⢠", "⢰", "⢸"],
  ["⡀", "⣀", "⣠", "⣰", "⣸"],
  ["⡄", "⣄", "⣤", "⣴", "⣴"],
  ["⡆", "⣆", "⣦", "⣶", "⣾"],
  ["⡇", "⣇", "⣧", "⣷", "⣿"],
]

proc histogram(s: seq[float64]): string =
  let
    avg = mean(s)
    std = stdDev(s)
    cell = std * 0.2
    bucketRanges = [int.low, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, int.high]
  var
    buckets: seq[float64]
  for i in 0 ..< bucketRanges.len - 1:
    let
      a = avg - cell * 9 + cell * bucketRanges[i].float64
      b = avg - cell * 9 + cell * bucketRanges[i + 1].float64
    buckets.add perBetween(s, a, b)

  let maxVal = max(buckets)
  var
    intBuckets: seq[int]
  for b in buckets.mitems:
    intBuckets.add (b / maxVal * 4).ceil.int

  var brailleChart = ""
  for i in 0 ..< intBuckets.len div 2:
    #echo intBuckets[i]#, ", ", intBuckets[i*2 + 1]
    brailleChart.add brailleArr[intBuckets[i*2]][intBuckets[i*2+1]]
  return brailleChart

var
  shownHeader = false # Only show the header once.
  keepInt: int # Results of keep template goes to this global.

template keep*(value: untyped) =
  ## Pass results of your computation here to keep the compiler from optimizing
  ## your computation to nothing.
  keepInt += 1
  {.emit: [keepInt, "+= (void*)&", value,";"].}
  keepInt = keepInt and 0xFFFF
  #keepInt = cast[int](value)

template timeIt*(tag: string, iterations: untyped, body: untyped) =
  ## Template to time the block of code.
  if not shownHeader:
    shownHeader = true
    var header = "   min time    avg time  std dv   runs "
    when defined(benchyHistogram):
      header.add "histogram "
    header.add "name"
    echo header
  var
    num = 0
    minTime: float64 = float64.high
    lastMinCount: int
    total: float64
    deltas: seq[float64]

  block:
    proc test() {.gensym.} =
      body

    when defined(benchyExtra):
      # warm up
      for i in 0 ..< 15:
        test()

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
      elif defined(benchyMinFinder):
        if minTime > delta:
          minTime = delta
          lastMinCount = 0
        inc lastMinCount
        if lastMinCount > 1000:
          break
        if total > 30_000.0:
          break
      else:
        if total > 5_000.0 or num >= 1000:
          break

  let minDelta = min(deltas)
  removeOutliers(deltas)
  let avgDelta = mean(deltas)
  let stdDev = stdDev(deltas)
  let median = median(deltas)

  var
    m, s, d: string
  formatValue(m, minDelta, "0.3f")
  formatValue(s, avgDelta, "0.3f")
  formatValue(d, stdDev, "0.3f")
  var row = align(m, 8) & " ms " & align(s, 8) & " ms " & align("±" & d, 8) & "  " & align("x" & $num, 5) & " "
  when defined(benchyHistogram):
    row.add histogram(deltas) & "  "
  row.add tag
  echo row

template timeIt*(tag: string, body: untyped) =
  ## Template to time block of code.
  timeIt(tag, 0, body)
