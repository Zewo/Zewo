Pod::Spec.new do |s|
  s.name = 'Aeon'
  s.version = '0.1'
  s.license = 'MIT'
  s.summary = 'GCD based HTTP server for Swift 2 (Linux ready)'
  s.homepage = 'https://github.com/Zewo/Aeon'
  s.authors = { 'Paulo Faria' => 'paulo.faria.rl@gmail.com' }
  s.source = { :git => 'https://github.com/Zewo/Aeon.git', :tag => 'v0.1' }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'

  s.source_files = 'Dependencies/Belle/*.c',
                   'Dependencies/Incandescence/*.c',
                   'Dependencies/Tide/*.c'
                   'Aeon/**/*.swift'

  s.xcconfig =  {
    'SWIFT_INCLUDE_PATHS' => '$(SRCROOT)/Aeon/Dependencies'
  }

  s.preserve_paths = 'Dependencies/*'

  s.requires_arc = true
end