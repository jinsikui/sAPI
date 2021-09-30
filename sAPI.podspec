#
#  Be sure to run `pod spec lint sAPI.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name             = 'sAPI'
  s.version          = '1.0.3.0'
  s.summary          = '提供链式api调用'

  s.description      = <<-DESC
    提供链式api调用的基础组件库
                       DESC

  s.homepage         = 'https://github.com/jinsikui/sAPI.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'jsk' => '914865302@qq.com' }
  s.source           = { :git => 'https://github.com/jinsikui/sAPI.git'}
  s.ios.deployment_target = '9.0'
  s.source_files = 'Source/Classes/sAPI.h'
  s.dependency 'PromisesObjC'
  s.dependency 'AFNetworking'
  
  s.subspec 'Helpers' do |sh|
    sh.source_files = 'Source/Classes/Helpers/*'
  end
  
  s.subspec 'Services' do |ss|
    ss.source_files = 'Source/Classes/Services/*'
  end

end
