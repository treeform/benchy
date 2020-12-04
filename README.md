# Benchy

Simple benchmarking to time your code. Just put your code in a `timeIt` block. Also put result of your computation into `keep()` so that compiler does not optimize it out. Don't forgot to run with `-d:release` or better yet `-d:danger`.

```nim
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
```

It will run the `timeIt` block at least 10 times but possibly more to figure out the standard divination. It will keep running it until things look like they stabilized. It will stop after 60s though.

```
sleep 1ms ........................... 1.988 ms    ±0.021  x10
sleep 200ms ....................... 200.565 ms    ±0.318  x10
sleep randms ....................... 85.690 ms   ±42.987  x10
number counter ...................... 0.000 ms    ±0.000  x10
string append ...................... 40.731 ms    ±2.135  x75
```
