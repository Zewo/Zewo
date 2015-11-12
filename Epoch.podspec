Pod::Spec.new do |s|
  s.name = 'Epoch'
  s.version = '0.1'
  s.license = 'MIT'
  s.summary = 'Venice based HTTP server for Swift 2 (Linux ready)'
  s.homepage = 'https://github.com/Zewo/Epoch'
  s.authors = { 'Paulo Faria' => 'paulo.faria.rl@gmail.com' }
  s.source = { :git => 'https://github.com/Zewo/Epoch.git', :tag => 'v0.1' }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'

  s.source_files = 'Dependencies/Incandescence/*.c',
                   'Dependencies/libmill/*.c'
                   'Epoch/**/*.swift'

  s.xcconfig =  {
    'SWIFT_INCLUDE_PATHS' => '$(SRCROOT)/Epoch/Dependencies'
  }

  s.preserve_paths = 'Dependencies/*'

  s.requires_arc = true
end