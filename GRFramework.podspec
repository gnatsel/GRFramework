#
# Be sure to run `pod lib lint GRFramework.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GRFramework'
  s.version          = '0.1.0'
  s.summary      = "A simple MVP framework"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This framework adds MVP support to the native iOS SDK and a lot of utilities
                       DESC

  s.homepage         = 'https://github.com/gnatsel/GRFramework'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Gnatsel Reivilo' => 'gnatsel.reivilo@gmail.com' }
  s.source           = { :git => 'https://github.com/gnatsel/GRFramework.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'GRFramework/Classes/**/*'
  
  # s.resource_bundles = {
  #   'GRFramework' => ['GRFramework/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'Argo'
  s.dependency 'Curry'
  s.dependency 'Alamofire', '~> 3.4'
  s.dependency "PromiseKit", "~> 3.0"
end
