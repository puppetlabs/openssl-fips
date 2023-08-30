project 'openssl-fips-client-tools' do |proj|
  prefix = 'client-tools'
  instance_eval File.read(File.join(File.dirname(__FILE__), '_shared-openssl-fips.rb'))
end 
