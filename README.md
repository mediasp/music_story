[![Build Status](https://travis-ci.org/mediasp/music_story.svg?branch=master)](https://travis-ci.org/mediasp/music_story)
[![Gem Version](https://badge.fury.io/rb/music_story.svg)](http://badge.fury.io/rb/music_story)

# Music Story

Wrapper code for MusicStory data products.

Usage:

```ruby
MusicStory::XMLParser.each_in_file('music-story-data.xml') do |artist|
  puts artist.name
  puts artist.plain_text_bio
  puts artist.main_genres[0].id
  # see MusicStory::{Artist,Genre} for more available properties
end
```

Should be able to cope with big XML files, as it uses an XML::Reader to scan through the file one artist at a time; only the current artist object is kept in memory. (Although only tried it on a 330KB file so far so YMMV...)
