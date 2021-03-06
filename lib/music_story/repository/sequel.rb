module MusicStory
  class Repository::Sequel
    def initialize(db)
      db = Sequel.connect(db) unless db.is_a?(Sequel::Database)
      @db = db
      @artist_repo = Repository::ArtistSequel.new(db)
      @genre_repo  = Repository::GenreSequel.new(db)
      [:similar_artists, :influenced_by_artists, :successor_artists].each do |prop|
        @artist_repo.mapper(prop).target_repo = @artist_repo
      end
      [:main_genres, :secondary_genres, :influenced_by_genres].each do |prop|
        @artist_repo.mapper(prop).target_repo = @genre_repo
      end
    end

    attr_reader :artist_repo, :genre_repo, :db

    def drop_tables!
      [:genres, :artist_associations, :artist_genres, :artists].each do |table|
        begin ; @db.drop_table(table) ; rescue ; end
      end
    end

    def create_tables!
      @db.create_table(:artist_associations, :ignore_index_errors=>true) do
        Integer :from_artist_id, :null=>false
        Integer :to_artist_id, :null=>false
        String :relation, :size=>16

        primary_key [:from_artist_id, :relation, :to_artist_id]

        index [:to_artist_id], :name=>:to_artist_id
      end

      @db.create_table(:artist_genres, :ignore_index_errors=>true) do
        Integer :artist_id, :null=>false
        Integer :genre_id, :null=>false
        String :relation, :size=>16

        primary_key [:artist_id, :relation, :genre_id]

        index [:genre_id], :name=>:genre_id
      end

      @db.create_table(:artists, :ignore_index_errors=>true) do
        primary_key :id
        String :name, :null=>false, :size=>255
        String :forename, :size=>255
        String :real_name, :size=>255
        String :role, :size=>64
        String :type, :size=>64
        String :country, :size=>64
        String :summary_html, :text=>true
        String :bio_html, :text=>true
        String :image_filename, :text=>true

        index [:name], :name=>:name
      end

      @db.create_table(:genres) do
        primary_key :id
        String :name, :null=>false, :size=>255
      end
    end
  end
end
