# -*- coding: utf-8; mode: tcl; c-basic-offset: 4; indent-tabs-mode: nil; tab-width: 4; truncate-lines: t -*- vim:fenc=utf-8:et:sw=4:ts=4:sts=4

# This PortGroup supports the meson build system
#
# Usage:
#
# PortGroup meson 1.0
#


# meson builds need to be done out-of-source
default build_dir           {${workpath}/build}

depends_skip_archcheck-append \
                            meson \
                            ninja

# TODO: --buildtype=plain tells Meson not to add its own flags to the command line. This gives the packager total control on used flags.
default configure.cmd       {${prefix}/bin/meson}
default configure.post_args {[meson::get_post_args]}
configure.universal_args-delete \
                            --disable-dependency-tracking

# Set "python3" to be used, keep in sync with meson port
set py_ver                  3.10
set py_ver_nodot            [string map {. {}} ${py_ver}]
configure.env-append        PATH=${frameworks_dir}/Python.framework/Versions/${py_ver}/bin:$env(PATH)

default build.dir           {${build_dir}}
default build.cmd           {${prefix}/bin/ninja}
default build.post_args     {-v}
default build.target        ""
build.env-append            PATH=${frameworks_dir}/Python.framework/Versions/${py_ver}/bin:$env(PATH)

# remove DESTDIR= from arguments, but rather take it from environmental variable
destroot.env-append         DESTDIR=${destroot}
destroot.env-append         PATH=${frameworks_dir}/Python.framework/Versions/${py_ver}/bin:$env(PATH)
default destroot.post_args  ""

namespace eval meson { }

proc meson::get_post_args {} {
    global configure.dir build_dir muniversal.current_arch
    if {[info exists muniversal.current_arch]} {
        return "${configure.dir} ${build_dir}-${muniversal.current_arch} --cross-file=${muniversal.current_arch}-darwin"
    } else {
        return "${configure.dir} ${build_dir}"
    }
}

proc meson::add_depends {} {
    depends_build-append    port:meson \
                            port:ninja
}
port::register_callback meson::add_depends
