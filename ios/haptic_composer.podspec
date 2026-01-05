#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint haptic_composer.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'haptic_composer'
  s.version          = '0.1.0'
  s.summary          = 'A Flutter package for designing custom haptic experiences.'
  s.description      = <<-DESC
haptic_composer is a Flutter package that makes it easy to add haptic feedback to your app.
Design custom haptic experiences as easily as composing music.
                       DESC
  s.homepage         = 'https://github.com/yourusername/haptic_composer'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
