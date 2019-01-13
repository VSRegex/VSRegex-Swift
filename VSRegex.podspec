Pod::Spec.new do |s|
  s.name = "VSRegex"
  s.version = "1.0.0"
  s.summary = "Regular expressions that match the mobile phone number in mainland China."
  s.homepage = "https://github.com/VSRegex/VSRegex-Swift"
  s.license = "MIT"
  s.author = {"VincentXue" => "vincentxueios@gmail.com"}
  s.social_media_url = "https://twitter.com/SuetFungSit"
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
  s.swift_version = "4.2"
  s.source = {:git => "https://github.com/VSRegex/VSRegex-Swift.git", :tag => "#{s.version}"}
  s.source_files = "Sources/VSRegex.swift"
  s.resource_bundles = {
    "VSRegex" => ["Sources/Resources/regex.json"],
  }
end
