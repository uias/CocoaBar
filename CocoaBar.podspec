Pod::Spec.new do |s|

  s.name         = "CocoaBar"
  s.version      = "0.3.0"
  s.summary      = "Snackbar for iOS."
  s.description  = <<-DESC
                    A flexible and simple to use SnackBar view for iOS.
                   DESC
  s.homepage     = "https://github.com/MerrickSapsford/CocoaBar"
  s.screenshots  = "https://raw.githubusercontent.com/MerrickSapsford/CocoaBar/develop/Resource/screenshot1.png", "https://raw.githubusercontent.com/MerrickSapsford/CocoaBar/develop/Resource/screenshot2.png"
  s.license      = "MIT"
  s.author             = { "Merrick Sapsford" => "merrick@sapsford.tech" }
  s.social_media_url   = "http://twitter.com/MerrickSapsford"
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/MerrickSapsford/CocoaBar.git", :tag => s.version.to_s }
  s.source_files  = "CocoaBar", "Sources/**/*.{swift}"
  s.resources = ['Sources/**/*.{xib}']

end
