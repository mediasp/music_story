require 'helpers'
require 'logger'

describe "MusicStory::Utils::XMLToDBImporter" do
  include MusicStory::TestHelpers

  it "should import artist xml file into a new database" do
    logger = ENV['DEBUG'] && Logger.new(STDOUT)
    @db = Sequel.sqlite(:logger => logger)

    result = MusicStory::Utils::XMLToDBImporter.import_file_into_db(test_xml_filename, @db, true)
    sequel_repos = result[:sequel_repos]
    artist = sequel_repos.artist_repo.get_by_id(42)

    assert_artist_correct_from_test_xml_file(artist)
  end
end
