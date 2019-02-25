Pod::Spec.new do |s|
# Version
s.version       = "1.0.2"
s.swift_version = "4.2"

# Meta
s.name         = "Elefont"
s.summary      = "Load fonts in your iOS app without any hassle."
s.homepage     = "https://github.com/mihaicristiantanase/Elefont"
s.license      = { :type => "MIT", :file => "LICENSE" }
s.authors      = { "Mihai Cristian Tanase" => "mihaicristian.tanase@gmail.com"}
s.description  = <<-DESC
                 Load fonts from main Bundle, custom Bundle or any local path on the device with only one line.
                 DESC

# Deployment Targets
s.ios.deployment_target = "8.0"
s.tvos.deployment_target = "9.0"

# Sources
s.source       = { :git => "https://github.com/mihaicristiantanase/Elefont.git", :tag => s.version.to_s }
s.source_files = 'Sources/'
s.requires_arc = true

end
