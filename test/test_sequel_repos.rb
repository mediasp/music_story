require 'helpers'
require 'logger'

describe "MusicStory::Repository::Sequel" do
  before do
    logger = ENV['DEBUG'] && Logger.new(STDOUT)
    @db = MusicStory::Repository::Sequel.new(Sequel.sqlite(:logger => logger))
    @db.create_tables!
  end
  
  it "should persist an artist" do
    artist = MusicStory::Model::Artist.new(
      :id           => 123456,
      :name         => 'Foo bar',
      :forename     => 'Foo',
      :real_name    => 'Johhny McPie',
      :role         => 'Compositeur',
      :type         => 'artiste',
      :country      => 'Nicauragua',
      :summary_html => 'Foo <b>Bar</b><br /> '*500,
      :bio_html     => 'Foo <b>Bar</b><br /> '*500
    )
    @db.artist_repo.store_new(artist)
    a2 = @db.artist_repo.get_by_id(123456)
    [:name, :forename, :real_name, :role, :type, :country, :summary_html, :bio_html].each do |p|
      assert_equal a2[p], artist[p]
    end
  end
  
  it "should persist artist associations" do
    artist = MusicStory::Model::Artist.new(
      :id   => 123,
      :name => 'Foo',
      :real_name => 'Pieface',
      :similar_artists => [
        MusicStory::Model::Artist.new(:id => 456, :name => 'Bar'),
        MusicStory::Model::Artist.new(:id => 789, :name => 'Baz')
      ],
      :influenced_by_artists => [
        MusicStory::Model::Artist.new(:id => 456, :name => 'Bar')
      ],
      :successor_artists => [
        MusicStory::Model::Artist.new(:id => 789, :name => 'Baz')
      ]
    )
    artist.all_associated_artists.each {|a| @db.artist_repo.store(a)}
    @db.artist_repo.store(artist)
    
    artist = @db.artist_repo.get_by_id(123)
    assert_equal 2, artist.similar_artists.length
    assert_equal 456, artist.similar_artists[0].id
    assert_equal 'Bar', artist.similar_artists[0].name
    assert_equal 789, artist.similar_artists[1].id
    assert_equal 'Baz', artist.similar_artists[1].name

    assert_equal 1, artist.influenced_by_artists.length
    assert_equal 456, artist.influenced_by_artists[0].id
    assert_equal 'Bar', artist.influenced_by_artists[0].name

    assert_equal 1, artist.successor_artists.length
    assert_equal 789, artist.successor_artists[0].id
    assert_equal 'Baz', artist.successor_artists[0].name
  end

  it "should persist genre associations" do
    artist = MusicStory::Model::Artist.new(
      :id   => 123,
      :name => 'Foo',
      :real_name => 'Pieface',
      :main_genres => [
        MusicStory::Model::Genre.new(:id => 456, :name => 'Rock'),
        MusicStory::Model::Genre.new(:id => 789, :name => 'Pop')
      ],
      :influenced_by_genres => [
        MusicStory::Model::Genre.new(:id => 456, :name => 'Rock')
      ],
      :secondary_genres => [
        MusicStory::Model::Genre.new(:id => 789, :name => 'Pop')
      ]
    )
    artist.all_genres.each {|g| @db.genre_repo.store(g)}
    @db.artist_repo.store(artist)
    
    artist = @db.artist_repo.get_by_id(123)
    assert_equal 2, artist.main_genres.length
    assert_equal 456, artist.main_genres[0].id
    assert_equal 'Rock', artist.main_genres[0].name
    assert_equal 789, artist.main_genres[1].id
    assert_equal 'Pop', artist.main_genres[1].name

    assert_equal 1, artist.influenced_by_genres.length
    assert_equal 456, artist.influenced_by_genres[0].id
    assert_equal 'Rock', artist.influenced_by_genres[0].name

    assert_equal 1, artist.secondary_genres.length
    assert_equal 789, artist.secondary_genres[0].id
    assert_equal 'Pop', artist.secondary_genres[0].name
  end

end