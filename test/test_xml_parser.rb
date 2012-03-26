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
end