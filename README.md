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
