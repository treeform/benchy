# Benchy

`nimble install benchy`

![Github Actions](https://github.com/treeform/benchy/workflows/Github%20Actions/badge.svg)

[API reference](https://nimdocs.com/treeform/benchy)

This library has no dependencies other than the Nim standard library.

## About

Simple benchmarking to time your code. Just put your code in a `timeIt` block. Also put result of your computation into `keep()` so that compiler does not optimize it out. Don't forgot to run with `-d:release` or better yet `-d:danger`.

```nim
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
```

It will run the `timeIt` block at least 10 times but possibly more to figure out the standard deviation. It will keep running it until things look like they stabilized. It will stop after 60s though.

```
name ............................... min time      avg time    std dv   runs
sleep 1ms .......................... 1.016 ms      1.993 ms    ±0.032  x1000
sleep 200ms ...................... 200.403 ms    200.463 ms    ±0.022    x25
sleep random ....................... 5.959 ms     75.490 ms   ±44.856    x67
number counter ..................... 2.680 ms      2.747 ms    ±0.052  x1000
string append ..................... 36.322 ms     37.796 ms    ±1.771   x127
```

See API Reference: https://nimdocs.com/treeform/benchy/benchy.html
