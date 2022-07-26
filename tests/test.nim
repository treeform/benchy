## Put your tests here.

import benchy, os, random

var benchyData: BenchyData

timeIt benchyData:
  sleep(1)

timeIt benchyData, "sleep 2ms":
  sleep(2)

timeIt benchyData, 100:
  sleep(1)

timeIt benchyData, "sleep 1ms", 10:
  sleep(1)

# import print
# print benchyData

assert benchyData.name == "sleep 1ms"
assert benchyData.repetitions == 10
# there was actually a bug in the code, for 10 iterations it would only add
# 9 values to delta that's why I moved the inc after the break condition.
assert benchyData.deltas.len == 10

timeIt "sleep 1ms":
  sleep(1)

timeIt "sleep 200ms":
  sleep(200)

timeIt "sleep random":
  sleep(rand(0 .. 150))

timeIt "number counter":
  var s = 0
  for i in 0 .. 1_000_000:
    s += s
  keep(s)

timeIt "string append":
  var s = "?"
  for i in 0 .. 26:
    s.add(s)
  keep(s)

timeIt "sleep 1ms x5", 5:
  sleep(1)

timeIt "sleep 200ms x5", 5:
  sleep(200)

timeIt "sleep random x20", 20:
  sleep(rand(0 .. 150))

timeIt "number counter x20", 20:
  var s = 0
  for i in 0 .. 1_000_000:
    s += s
  keep(s)

timeIt "string append x20", 20:
  var s = "?"
  for i in 0 .. 26:
    s.add(s)
  keep(s)

import strutils

proc isSpace(c: char): bool =
  result = c in Whitespace

timeIt "isSpaceAscii", 1000:
  for n in 0 .. 1000:
    for i in 1..255:
      let c = char(i)
      keep isSpaceAscii(c)

timeIt "isSpace", 1000:
  for n in 0 .. 1000:
    for i in 1..255:
      let c = char(i)
      keep isSpace(c)

proc test() =
  # See https://github.com/treeform/benchy/pull/10
  discard
timeIt "test function":
  test()
