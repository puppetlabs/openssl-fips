project 'openssl-fips' do |proj|

  proj.version_from_git
  proj.generate_archives true
  proj.generate_packages false

  proj.description 'OpenSSL FIPS module'
  proj.license 'See components'
  proj.vendor 'Puppet, Inc.  <info@puppet.com>'
  proj.homepage 'https://puppet.com'
  proj.identifier 'com.puppetlabs'

  if platform.is_windows?
  else
    proj.setting(:install_root, "/opt/puppetlabs")
    proj.setting(:install_prefix, 'INSTALL_PREFIX=/')
  end

  proj.setting(:prefix, File.join(proj.install_root, "puppet"))
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
  # REMIND: we don't install pl-build-tools on redhatfips-8
  proj.setting(:cppflags, "-I#{proj.includedir} -I/opt/pl-build-tools/include")
  proj.setting(:cflags, "#{proj.cppflags}")
  proj.setting(:ldflags, "-L#{proj.libdir} -L/opt/pl-build-tools/lib -Wl,-rpath=#{proj.libdir}")

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
end
