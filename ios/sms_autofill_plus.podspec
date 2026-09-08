#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
#
# Upstream ships this as sms_otp_autofill.podspec / s.name = sms_otp_autofill,
# but Flutter CocoaPods expects the file and pod name to match the package
# name (sms_autofill_plus). Local vendored patch of sms_autofill_plus 1.0.0.
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
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end

