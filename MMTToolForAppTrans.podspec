#
# Be sure to run `pod lib lint MMTToolForAppTrans.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MMTToolForAppTrans'
  s.version          = '0.6.1'
  s.summary          = 'Bundle-first localization library with runtime language switching.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
MMTToolForAppTrans is a facade-driven localization library.
It can register a localization bundle at runtime, resolve keys with
language fallback, and read from storage when the bundle does not
provide the requested value.

The library also includes a 200-entry in-memory LRU cache and bundle-first
lookup flow with inline comments around the main runtime paths.
                       DESC

  s.homepage         = 'https://github.com/NealWills/MMTToolForAppTrans'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'NealWills' => 'aoiiiiyuki@outlook.com' }
  s.source           = { :git => 'https://github.com/NealWills/MMTToolForAppTrans.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'
  s.swift_versions = ['5.9']

  s.source_files = 'MMTToolForAppTrans/Classes/**/*'
  
  # s.resource_bundles = {
  #   'MMTToolForAppTrans' => ['MMTToolForAppTrans/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.frameworks = 'Foundation', 'UIKit'
  s.dependency 'MMTToolForXCGLog'
  s.dependency 'WCDB.swift'
  
end
