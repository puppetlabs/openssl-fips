component 'openssl' do |pkg, settings, platform|
  pkg.version '3.0.0'
  pkg.sha256sum '59eedfcb46c25214c9bd37ed6078297b4df01d012267fe9e9eee31f61bc70536'

  pkg.url "https://openssl.org/source/openssl-#{pkg.get_version}.tar.gz"
  pkg.mirror "#{settings[:buildsources_url]}/openssl-#{pkg.get_version}.tar.gz"

  #############
  # ENVIRONMENT
  #############

  # OpenSSL 3 accepts CFLAGS, etc environment variables (unlike 1.1.1)

  if platform.is_el? && platform.is_fips?
    pkg.build_requires 'perl-core'

    pkg.environment 'PATH', '/opt/pl-build-tools/bin:$(PATH):/usr/local/bin'
    pkg.environment 'CFLAGS', settings[:cflags]
    pkg.environment 'LDFLAGS', "#{settings[:ldflags]} -Wl,-z,relro"

    target = 'linux-x86_64'
  elsif platform.is_windows?
    pkg.build_requires 'strawberryperl'

    pkg.environment 'PATH', "$(shell cygpath -u #{settings[:gcc_bindir]}):$(PATH)"

    target = 'mingw64'
  else
    raise 'The openssl-fips component is only supported on RHEL and Windows'
  end

  ###########
  # CONFIGURE
  ###########

  configure_flags = [
    "--prefix=#{settings[:prefix]}",
    '--libdir=lib',
    "--openssldir=#{settings[:ssldir]}",
    'shared',
    target,
    'enable-fips'
  ]

  pkg.configure do
    ["./Configure #{configure_flags.join(' ')}"]
  end

  #######
  # BUILD
  #######

  pkg.build do
    [
      platform[:make]
    ]
  end

  #########
  # INSTALL
  #########

  install_prefix = platform.is_windows? ? '' : 'INSTALL_PREFIX=/'
  pkg.install do
    [
      "#{platform[:make]} #{install_prefix} install_fips",
      "rm /opt/puppetlabs/puppet/ssl/fipsmodule.cnf",
    ]
  end
end
