project 'openssl-fips' do |proj|
  proj.setting(:prefix, File.join(proj.install_root, "puppet"))
  instance_eval File.read(File.join(File.dirname(__FILE__), '_shared-openssl-fips.rb'))
end
