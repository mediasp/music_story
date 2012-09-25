module MusicStory
  module Model; end
  module Repository; end
  module Utils; end
end

# alias it
Musicstory = MusicStory

require 'nokogiri'
require 'music_story/utils/html_to_text'
require 'music_story/utils/xml_to_db_importer'

require 'thin_models/struct/identity'
require 'music_story/model/artist'
require 'music_story/model/genre'

require 'music_story/repository/artist_xml_file'

require 'sequel'
require 'persistence'
require 'persistence/sequel'
require 'music_story/repository/artist_sequel'
require 'music_story/repository/genre_sequel'
require 'music_story/repository/sequel'
