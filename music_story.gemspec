# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'music_story/version'

spec = Gem::Specification.new do |s|
  s.name     = 'music_story'
  s.version  = MusicStory::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors  = ['Matthew Willson']
  s.email    = ['mark@mediasp.com', 'tom@mediasp.com', 'devs@playlouder.com']
  s.summary  = 'Wrapper code for the MusicStory data product'
  s.homepage = 'https://github.com/mediasp/music_story'
  s.license = 'MIT'

  s.add_dependency('sequel', '>= 3.11.0')
  s.add_dependency('hold', '~> 1.0')
  s.add_dependency('thin_models', '>= 0.1.4')
  s.add_dependency('nokogiri', '>= 1.5.0')
  s.add_dependency('net-sftp')

  s.add_development_dependency('minitest')
  s.add_development_dependency('sqlite3')
  s.add_development_dependency('mock_sftp')

  s.files = Dir.glob("lib/**/*") + ['README.md']
end
