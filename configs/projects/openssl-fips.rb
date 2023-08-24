project 'openssl-fips' do |proj|
  # the directory under the install_root is the only difference currently between the fips module for bolt and puppet agent
  prefix = 'puppet'
  instance_eval File.read(File.join(File.dirname(__FILE__), '_shared-openssl-fips.rb'))
end
