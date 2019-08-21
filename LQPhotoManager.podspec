#
#  Be sure to run `pod spec lint LQPhotoManager.podspec.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|
  spec.name         = "LQPhotoManager"
  spec.version      = "1.0.0"
  spec.summary      = "iOS Photos库和UIImagePickerController的封装"
  spec.homepage     = "https://github.com/lqIphone/LQPhotoManager"
  spec.license      = "MIT"
  spec.author             = { "Quan Li" => "10.83099465@qq.com" }
  spec.platform     = :ios, "9.0"
  spec.source       = { :git => "https://github.com/lqIphone/LQPhotoManager.git", :tag => "1.0.0" }
  spec.source_files = "LQPhotoManager/Classes/*.swift"
  spec.framework  = "Photos"
  spec.requires_arc = true
  spec.swift_version = "4.2"
end
