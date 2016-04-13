Pod::Spec.new do |s|

s.name         = 'ESRequest'
s.version      = '0.1.3'
s.summary      = 'Request.'
s.homepage     = 'https://github.com/cezres/ESRequest'
s.license      = { :type => 'MIT', :file => 'LICENSE' }
s.author       = { 'cezres' => 'cezres@163.com' }

s.platform     = :ios, '7.0'
s.source       = { :git => 'https://github.com/cezres/ESRequest.git', :tag => s.version }
s.source_files = 'ESRequest'
s.requires_arc = true
s.public_header_files = 'ESRequest/*.h'

s.dependency 'AFNetworking', '~> 3.0'
s.dependency 'MBProgressHUD'

end
