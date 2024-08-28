platform 'windowsfips-2016-x64' do |plat|
  plat.vmpooler_template 'win-2016-fips-x86_64'
  plat.servicetype 'windows'
  
  # We need to ensure we install chocolatey prior to adding any nuget repos. Otherwise, everything will fall over
  plat.add_build_repository 'https://artifactory.delivery.puppetlabs.net/artifactory/generic/buildsources/windows/chocolatey/install-chocolatey-1.4.0.ps1'
  plat.provision_with 'C:/ProgramData/chocolatey/bin/choco.exe feature enable -n useFipsCompliantChecksums'
  
  plat.add_build_repository 'https://artifactory.delivery.puppetlabs.net/artifactory/api/nuget/nuget'
  
  # C:\tools is likely added by mingw, but create it explicitly. The runtime
  # does this because it installs MSVC, to compile pxp-agent, but we don't
  # since it's not needed.
  plat.provision_with 'mkdir -p C:/tools'
  
  # We don't want to install any packages from the chocolatey repo by accident
  plat.provision_with 'C:/ProgramData/chocolatey/bin/choco.exe sources remove -name chocolatey'
  
  plat.provision_with 'C:/ProgramData/chocolatey/bin/choco.exe install -y mingw-w64 -version 5.2.0 -debug --no-progress'
  plat.provision_with 'C:/ProgramData/chocolatey/bin/choco.exe install -y pl-toolchain-x64 -version 2015.12.01.1 -debug --no-progress'
  
  plat.install_build_dependencies_with 'C:/ProgramData/chocolatey/bin/choco.exe install -y --no-progress'
  
  plat.make '/usr/bin/make'
  plat.patch 'TMP=/var/tmp /usr/bin/patch.exe --binary'
  
  plat.platform_triple 'x86_64-w64-mingw32'
  
  plat.package_type 'archive'
  plat.output_dir 'windowsfips'
end
  