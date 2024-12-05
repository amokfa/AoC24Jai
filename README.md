# Advent of code 2024 in Jai

## How to run:

```
jai build.jai - -day 3 -part 1 && ./a.out
```

* You'll need to save the input in `.input_cache/{day}`.
* If you login to advent of code website, copy the session cookie,
and save it to `.apikey`, `build.jai` will automatically download missing input and save it to input cache.
* Input will be read from `.input` if you pass `-temp_input`
* You can pass `-clipboard` to `build.jai` if you want it use the text in the clipboard as input. Won't work on non-linux OS.