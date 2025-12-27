#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint bactrack_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'bactrack_flutter'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin for BACtrack Bluetooth breathalyzers.'
  s.description      = <<-DESC
A Flutter plugin that wraps the official BACtrack SDK for iOS and Android.
Enables connecting to BACtrack Bluetooth breathalyzers and collecting BAC readings.
                       DESC
  s.homepage         = 'https://github.com/wellcentiv/bactrack_flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Wellcentiv' => 'dev@wellcentiv.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.vendored_frameworks = 'Frameworks/BreathalyzerSDK.xcframework'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # Privacy manifest for Bluetooth usage
  s.resource_bundles = {'bactrack_flutter_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
