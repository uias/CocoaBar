Pod::Spec.new do |s|

  s.name         = "CocoaBar"
  s.version      = "0.1.0"
  s.summary      = "A flexible and simple to use SnackBar view for iOS"
  s.description  = <<-DESC
                    A flexible and simple to use SnackBar view for iOS. Written in Swift 2.2.
                   DESC
  s.homepage     = "https://github.com/MerrickSapsford/CocoaBar"
  s.screenshots  = "https://github.com/MerrickSapsford/CocoaBar/blob/develop/Resource/screenshot1.png", "https://github.com/MerrickSapsford/CocoaBar/blob/develop/Resource/screenshot2.png"
  s.license      = "MIT"
  s.author             = { "Merrick Sapsford" => "merrick@sapsford.tech" }
  s.social_media_url   = "http://twitter.com/Merrick Sapsford"
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/MerrickSapsford/CocoaBar.git", :tag => s.version.to_s }
  s.source_files  = "CocoaBar", "Source/**/*.{h,m}"
  s.resources = ['Source/**/*.{xib}']

end
