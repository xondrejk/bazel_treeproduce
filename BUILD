load("//tools:mygen.bzl", "cc_mygen_library")

cc_mygen_library(
    name = "mylib",
    srcs = [":mydef.txt"],
)

cc_binary(
    name = "myexec",
    srcs = [],
    deps = [":mylib"],
)
# vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab:

