Pod::Spec.new do |s|

  s.name         = "SwipeSelectingCollectionView"
  s.version      = "0.1.5"
  s.summary      = "A collection view subclass that enables swipe to select multiple cells just like in Photos app."

  s.description  = <<-DESC
This collection view subclass is capable of selecting multiple cells with swipe.
Inspired by Photos app in iOS 9+.
                   DESC

  s.homepage     = "https://github.com/ShaneQi/SwipeSelectingCollectionView"
  s.license      = "Apache License 2.0"

  s.author             = { "Shane Qi" => "qizengtai@gmail.com" }
  s.social_media_url   = "http://twitter.com/shadowqi"

  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/ShaneQi/SwipeSelectingCollectionView.git", :tag => "#{s.version}" }

  s.source_files  = "Sources"
  s.swift_version = ["4.0", "4.2", "5.0"]

end
