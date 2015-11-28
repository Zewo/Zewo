Pod::Spec.new do |s|
  s.name = 'Epoch'
  s.version = '0.4'
  s.license = 'MIT'
  s.summary = 'Venice based HTTP server for Swift 2 (Linux ready)'
  s.homepage = 'https://github.com/Zewo/Epoch'
  s.authors = { 'Paulo Faria' => 'paulo.faria.rl@gmail.com' }
  s.source = { :git => 'https://github.com/Zewo/Epoch.git', :tag => s.version }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'

  s.source_files = 'Epoch/**/*.swift'

  s.dependency 'Venice', '0.9'
  s.dependency 'HTTP'

  s.requires_arc = true
end