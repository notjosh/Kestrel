source 'https://rubygems.org'

gem 'cocoapods', '~> 1.5'

group :development do
  gem 'aws-sdk', '~> 3'
  gem 'fastlane'
end

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval(File.read(plugins_path), binding) if File.exist?(plugins_path)

