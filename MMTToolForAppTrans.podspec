#
# Be sure to run `pod lib lint MMTToolForAppTrans.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MMTToolForAppTrans'
  s.version          = '0.1.0'
  s.summary          = 'Translation utility for extracting fields from Excel/XML files.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
MMTToolForAppTrans is a translation-focused utility library.
It accepts external files in Excel or XML format, parses the content,
and extracts translatable fields for processing.

The library also includes an LPU mechanism to persist the most recently
used 200 characters, helping optimize repeated translation input.
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
  s.dependency 'MMTToolForXCGLog'
  s.dependency 'WCDB'
  
end
