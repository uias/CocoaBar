Pod::Spec.new do |s|

  s.name         = "CocoaBar"
  s.version      = "0.1.0"
  s.summary      = "A flexible and simple to use SnackBar view for iOS"

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description  = <<-DESC
                   DESC

  s.homepage     = "https://github.com/MerrickSapsford/CocoaBar"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"
  s.license      = "MIT"
  s.author             = { "Merrick Sapsford" => "merrick@sapsford.tech" }
  s.social_media_url   = "http://twitter.com/Merrick Sapsford"
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/MerrickSapsford/CocoaBar.git", :tag => s.version.to_s }

  s.source_files  = "CocoaBar", "Source/**/*.{h,m}"
  s.resources = ['Source/**/*.{xib}']

end
