#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint sms_autofill_plus.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'sms_autofill_plus'
  s.version          = '1.0.0'
  s.summary          = 'Flutter plugin to provide SMS code autofill support'
  s.description      = <<-DESC
Flutter plugin to provide SMS code autofill support
                       DESC
  s.homepage         = 'https://github.com/shirsh94/sms_autofill_plus'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'shirsh94' => 'shirsh.shukla@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end