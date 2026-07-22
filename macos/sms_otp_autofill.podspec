#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint sms_otp_autofill.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'sms_otp_autofill'
  s.version          = '2.5.0'
  s.summary          = 'Flutter plugin to provide SMS code autofill support'
  s.description      = <<-DESC
Flutter plugin to provide SMS code autofill support
                       DESC
  s.homepage         = 'https://github.com/shirsh94/sms_otp_autofill'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'shirsh94' => 'shirsh.shukla@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
