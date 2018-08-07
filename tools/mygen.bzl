MyTrees = provider(fields=["sources", "headers"])

def _mygen_impl(ctx):
    args = ctx.actions.args()
    treeC = ctx.actions.declare_directory("files.c")
    treeH = ctx.actions.declare_directory("files.h")
    args.add(ctx.files.srcs[0])
    args.add(treeC.path)
    args.add(treeH.path)
    ctx.actions.run(
        inputs = ctx.files.srcs,
        outputs = [treeC, treeH],
        arguments = [args],
        executable = ctx.executable._mygen,
    )
    return [MyTrees(sources=depset([treeC]), headers=depset([treeH]))]

mygen = rule(
    implementation=_mygen_impl,
    output_to_genfiles = True,
    attrs={
        "srcs": attr.label_list(allow_files=True),
        "_mygen": attr.label(
            cfg="host",
            executable=True,
            allow_files=True,
            default=":mygen_sh",
        ),
    },
)


def _get_headers_impl(ctx):
    return [DefaultInfo(files=ctx.attr.src[MyTrees].headers)]

_get_headers = rule(
    implementation=_get_headers_impl,
    attrs={
        "src": attr.label(providers=[MyTrees])
    },
)


def _get_sources_impl(ctx):
    return [DefaultInfo(files=ctx.attr.src[MyTrees].sources)]

_get_sources = rule(
    implementation=_get_sources_impl,
    attrs={
        "src": attr.label(providers=[MyTrees])
    },
)


def cc_mygen_library(name, srcs):
    mygen(
        name="{}_generated".format(name),
        srcs=srcs,
    )

    _get_headers(
        name="{}_generated_headers".format(name),
        src=":{}_generated".format(name),
    )

    _get_sources(
        name="{}_generated_sources".format(name),
        src=":{}_generated".format(name),
    )

    native.cc_library(
        name = "{}_headers".format(name),
        hdrs = ["{}_generated_headers".format(name)],
    )

    native.cc_library(
        name = name,
        srcs = [":{}_generated_sources".format(name)],
        deps = ["{}_headers".format(name)],
    )
# vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab:
