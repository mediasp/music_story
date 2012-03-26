# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'music_story/version'

spec = Gem::Specification.new do |s|
  s.name     = "music_story"
  s.version  = MusicStory::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors  = ['Matthew Willson']
  s.email    = ["matthew@playlouder.com"]
  s.summary  = "Wrapper code for the MusicStory data product"

  s.add_dependency("sequel", "~> 3.11.0")
  s.add_dependency("persistence", "~> 0.3.1")
  s.add_dependency("thin_models", "~> 0.1.4")
  s.add_dependency("nokogiri", "~> 1.5.0")

  s.add_development_dependency("minitest")
  s.add_development_dependency("sqlite3")

  s.files = Dir.glob("lib/**/*") + ['README.txt']
end
