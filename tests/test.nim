## Put your tests here.

import benchy, os, random

timeIt "sleep 1ms", 100:
  sleep(1)

timeIt "sleep 200ms", 5:
  sleep(200)

timeIt "sleep randms", 10:
  sleep(rand(0 .. 150))

timeIt "number counter", 10:
  var s = 0
  for i in 0 .. 1_000_000:
    s += s
  keep(s)

timeIt "string append", 10:
  var s = "?"
  for i in 0 .. 26:
    s.add(s)
  keep(s)
