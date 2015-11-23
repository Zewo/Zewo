Pod::Spec.new do |s|
  s.name = 'Epoch'
  s.version = '0.3'
  s.license = 'MIT'
  s.summary = 'Venice based HTTP server for Swift 2 (Linux ready)'
  s.homepage = 'https://github.com/Zewo/Epoch'
  s.authors = { 'Paulo Faria' => 'paulo.faria.rl@gmail.com' }
  s.source = { :git => 'https://github.com/Zewo/Epoch.git', :tag => 'v0.3' }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'

  s.source_files = 'Epoch/**/*.swift',
                   'HTTPServerType/**/*.swift'

  s.dependency 'Venice', '0.9'
  s.dependency 'Luminescence', '0.3'
  s.dependency 'Curvature', '0.1'
  s.dependency 'Otherside', '0.1'

  s.requires_arc = true
end