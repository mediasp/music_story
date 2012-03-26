module MusicStory
  module Model; end
  module Repository; end
end
require 'nokogiri'
require 'thin_models/struct/identity'
require 'music_story/model/artist'
require 'music_story/model/genre'
require 'music_story/html_to_text'
require 'music_story/repository/artist_xml_file'