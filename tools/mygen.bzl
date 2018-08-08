def _mygen_impl(ctx):
    args = ctx.actions.args()
    treeC = ctx.actions.declare_directory("files.c")
    treeH = ctx.actions.declare_directory("files.h")
    args.add(ctx.files.srcs[0])
    args.add(treeC.path)
    args.add(treeH.path)
    sources = []
    headers = []
    for genfile in ctx.files.generated:
        if genfile.extension.lower() == 'c':
            sources.append(ctx.actions.declare_file('/'.join((treeC.basename, genfile.path))))
        elif genfile.extension.lower() == 'h':
            headers.append(ctx.actions.declare_file('/'.join((treeH.basename, genfile.path))))
        else:
            fail("Only understand .c or .h", attr="generated")
    generated = sources + headers
    ctx.actions.run(
        inputs = ctx.files.srcs,
        outputs = generated + [treeC, treeH],
        arguments = [args],
        executable = ctx.executable._mygen,
    )
    return [DefaultInfo(files=depset(generated))]

mygen = rule(
    implementation=_mygen_impl,
    output_to_genfiles = True,
    attrs={
        "srcs": attr.label_list(allow_files=True),
        "generated": attr.label_list(allow_files=True),
        "_mygen": attr.label(
            cfg="host",
            executable=True,
            allow_files=True,
            default=":mygen_sh",
        ),
    },
)

def cc_mygen_library(name, srcs, generated):
    mygen(
        name="{}_generated".format(name),
        srcs=srcs,
        generated=generated,
    )

    native.cc_library(
        name = name,
        srcs = [":{}_generated".format(name)],
        hdrs = [":{}_generated".format(name)],
    )
# vim: set tabstop=4 softtabstop=4 shiftwidth=4 expandtab:
