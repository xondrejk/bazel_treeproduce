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
    return [DefaultInfo(files=depset([treeC, treeH]))]

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

def cc_mygen_library(name, srcs):
    mygen(
        name="{}_generated".format(name),
        srcs=srcs,
    )

    native.cc_library(
        name = name,
        srcs = [":{}_generated".format(name)],
        hdrs = [":{}_generated".format(name)],
    )
# vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab:
