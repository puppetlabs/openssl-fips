proj.version_from_git
proj.generate_archives true
proj.generate_packages false

proj.description 'OpenSSL FIPS module'
proj.license 'See components'
proj.vendor 'Puppet, Inc.  <info@puppet.com>'
proj.homepage 'https://puppet.com'
proj.identifier 'com.puppetlabs'

if platform.is_windows?
    proj.setting(:company_id, "PuppetLabs")
    proj.setting(:product_id, "Puppet")
    proj.setting(:base_dir, "ProgramFiles64Folder")

    # We build for windows not in the final destination, but in the paths that correspond
    # to the directory ids expected by WIX. This will allow for a portable installation (ideally).
    proj.setting(:install_root, File.join("C:", proj.base_dir, proj.company_id, proj.product_id))
    proj.setting(:install_prefix, '')
else
    proj.setting(:install_root, "/opt/puppetlabs")
    proj.setting(:install_prefix, 'INSTALL_PREFIX=/')
end

proj.setting(:bindir, File.join(proj.prefix, "bin"))
proj.setting(:libdir, File.join(proj.prefix, "lib"))
proj.setting(:ssldir, File.join(proj.prefix, "ssl"))
proj.setting(:includedir, File.join(proj.prefix, "include"))
proj.setting(:fipsmodule_cnf, File.join(proj.ssldir, 'fipsmodule.cnf'))

proj.setting(:artifactory_url, "https://artifactory.delivery.puppetlabs.net/artifactory")
proj.setting(:buildsources_url, "#{proj.artifactory_url}/generic/buildsources")

# Define default CFLAGS and LDFLAGS for most platforms, and then
# tweak or adjust them as needed.
#
if platform.is_windows?
    arch = platform.architecture == "x64" ? "64" : "32"
    proj.setting(:gcc_root, "C:/tools/mingw64")
    proj.setting(:gcc_bindir, "#{proj.gcc_root}/bin")
    proj.setting(:tools_root, "C:/tools/pl-build-tools")
    proj.setting(:cppflags, "-I#{proj.tools_root}/include -I#{proj.gcc_root}/include -I#{proj.includedir}")
    proj.setting(:cflags, "#{proj.cppflags}")
    # nxcompat: enable DEP
    # dynamicbase: enable ASLR
    proj.setting(:ldflags, "-L#{proj.tools_root}/lib -L#{proj.gcc_root}/lib -L#{proj.libdir} -Wl,--nxcompat -Wl,--dynamicbase")

    proj.setting(:cygwin, "nodosfilewarning winsymlinks:native")
else
    # REMIND: we don't install pl-build-tools on redhatfips-8
    proj.setting(:cppflags, "-I#{proj.includedir} -I/opt/pl-build-tools/include")
    proj.setting(:cflags, "#{proj.cppflags}")
    # -z,relro: partial read-only relocations
    proj.setting(:ldflags, "-L#{proj.libdir} -L/opt/pl-build-tools/lib -Wl,-rpath=#{proj.libdir} -Wl,-z,relro")
end

# Harden Linux ELF binaries by compiling with PIE (Position Independent Executables) support,
# stack canary and full RELRO.
# We only do this on platforms that use their default OS toolchain since pl-gcc versions
# are too old to support these flags.

# REMIND: this doesn't match redhatfips-8 platform name, so we're not compiling
# openssl with PIC...
if platform.name =~ /el-8/
    proj.setting(:cppflags, "-I#{proj.includedir} -D_FORTIFY_SOURCE=2")
    proj.setting(:cflags, '-fstack-protector-strong -fno-plt -O2')
    proj.setting(:ldflags, "-L#{proj.libdir} -Wl,-rpath=#{proj.libdir},-z,relro,-z,now")
end

proj.directory proj.libdir
proj.directory proj.ssldir

proj.component "openssl"
