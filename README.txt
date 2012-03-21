Wrapper code for MusicStory data products.

Usage:

    MusicStory::XMLParser.each_in_file('music-story-data.xml') do |artist|
      puts artist.name
      puts artist.plain_text_bio
      puts artist.main_genres[0].id
      # see MusicStory::{Artist,Genre} for more available properties
    end

Should be able to cope with big XML files, as it uses an XML::Reader to scan through
the file one artist at a time; only the current artist object is kept in memory. (Although only tried it on a 330KB file so far so YMMV...)