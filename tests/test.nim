## Put your tests here.

import benchy, os, random

timeIt "sleep 1ms":
  sleep(1)

timeIt "sleep 200ms":
  sleep(200)

timeIt "sleep randms":
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

timeIt "sleep randms x20", 20:
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
