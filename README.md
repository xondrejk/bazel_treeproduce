# bazel_treeproduce

A small sample to reproduce tree artifacts trouble for a generated source tree with an apetite to change interfaces. So, yeah, really it's the example that is broken, but unfortunately some things are bestowed upon us so we need to try to adjust the world instead.

## How to reproduce

1. `bazel build //:myexec`
2. Now change `mydef.txt` to say for instance `fce2`.
3. rerun `bazel build //:myexec`

## What just happend?

The problem is (whithout `bazel clean`) that we generate to files `main.c` and `another.c`. The former uses a function from the latter, but does so through a CPP macro. After we've generated and built `myexec`, we change input of the "generator" resulting in a changes in `another.c` which is also reflected in its exposed interface in `another.h`, but `main.c` remained unchanged. Since we could not tell bazel explicitly that `main.c` needs `another.h` and it's change on new "generator" run should have caused a recompilation, old object file for `main` is used, while `another` is refreshed. When we then try to link this mix, it (of course) fails.
