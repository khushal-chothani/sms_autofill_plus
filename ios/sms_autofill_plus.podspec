#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
#
# Upstream ships this as sms_otp_autofill.podspec / s.name = sms_otp_autofill,
# but Flutter CocoaPods expects the file and pod name to match the package
# name (sms_autofill_plus).
#
Pod::Spec.new do |s|
  s.name             = 'sms_autofill_plus'
  s.version          = '1.0.1'
  s.summary          = 'Flutter plugin to provide SMS code autofill support'
  s.description      = <<-DESC
Flutter plugin to provide SMS code autofill support
                       DESC
  s.homepage         = 'https://github.com/shirsh94/sms_autofill_plus'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'shirsh94' => 'shirsh.shukla@gmail.com' }
  s.source           = { :path => '.' }
  # Swift-only: SPM forbids mixing ObjC + Swift in one target. Keep Pigeon swiftOut only.
  s.source_files = 'sms_autofill_plus/Sources/sms_autofill_plus/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
