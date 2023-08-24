project 'openssl-fips-bolt-services' do |proj|
  proj.setting(:prefix, File.join(proj.install_root, "server/apps/bolt-server"))
  instance_eval File.read(File.join(File.dirname(__FILE__), '_shared-openssl-fips.rb'))
end
