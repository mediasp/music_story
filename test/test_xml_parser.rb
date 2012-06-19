require 'helpers'

describe "MusicStory::Repository::ArtistXMLFile" do

  include MusicStory::TestHelpers

  # reasonably comprehensive end-to-end test which should cover all the essentials
  # of what's a fairly mechanical data conversion:
  it "should correctly parse artists in a test XML file" do
    artists = nil
    MusicStory::Repository::ArtistXMLFile.new_with_open_file(test_xml_filename) do |repo|
      artists = repo.get_all.to_a
    end

    assert_equal 1, artists.length
    assert_artist_correct_from_test_xml_file(artists.first)
  end

  it "should silently skip artist associations that are missing required attributes" do
    test_filename = 'test/test-data-with-broken-association.xml'
    artists = nil
    MusicStory::Repository::ArtistXMLFile.new_with_open_file(test_filename) do |repo|
      artists = repo.get_all.to_a
    end

    assert_equal 1, artists.length
    artist = artists.first
    assert_equal 1, artist.successor_artists.size

    assert_equal 1, artist.successor_artists.size
    successor = artist.successor_artists.first
    assert successor
    assert_equal 'Arthur H', successor.name
    assert_equal 1777, successor.id

    assert_equal 1, artist.similar_artists.size, artist.similar_artists
    similar = artist.similar_artists.first
    assert similar
    assert_equal 'Benjamin Biolay', similar.name
    assert_equal 1218, similar.id
  end

end
