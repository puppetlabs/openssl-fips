component 'openssl' do |pkg, settings, platform|
  pkg.version '3.0.9'
  pkg.sha256sum 'eb1ab04781474360f77c318ab89d8c5a03abc38e63d65a603cabbf1b00a1dc90'

  pkg.url "https://openssl.org/source/openssl-#{pkg.get_version}.tar.gz"
  pkg.mirror "#{settings[:buildsources_url]}/openssl-#{pkg.get_version}.tar.gz"

  #############
  # ENVIRONMENT
  #############

  # OpenSSL 3 accepts CFLAGS, etc environment variables (unlike 1.1.1)

  if platform.is_el? && platform.is_fips?
    pkg.build_requires 'perl-core'

    pkg.environment 'PATH', '/opt/pl-build-tools/bin:$(PATH):/usr/local/bin'

    target = 'linux-x86_64'
  elsif platform.is_windows?
    pkg.build_requires 'strawberryperl'

    pkg.environment 'PATH', "$(shell cygpath -u #{settings[:gcc_bindir]}):$(PATH)"

    target = 'mingw64'
  else
    raise 'The openssl-fips component is only supported on RHEL and Windows'
  end

  pkg.environment 'CFLAGS', settings[:cflags]
  pkg.environment 'LDFLAGS', settings[:ldflags]

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

  pkg.install do
    [
      "#{platform[:make]} #{settings[:install_prefix]} install_fips",
      "rm #{settings[:fipsmodule_cnf]}"
    ]
  end
end
