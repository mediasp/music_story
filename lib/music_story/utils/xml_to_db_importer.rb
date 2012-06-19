module MusicStory
  class Utils::XMLToDBImporter
    def self.import_file_into_db(filename, db, create_tables=false)
      sequel_repos = Repository::Sequel.new(db)
      sequel_repos.create_tables! if create_tables
      results = Repository::ArtistXMLFile.new_with_open_file(filename) do |xml_repo|
        new(xml_repo, sequel_repos).import
      end

      return results.merge(:sequel_repos => sequel_repos)
    end

    def initialize(xml_repo, sequel_repos)
      @xml_repo = xml_repo
      @sequel_repos = sequel_repos
    end

    def import
      failures = []
      successes = []

      @xml_repo.each do |artist|
        begin
          @sequel_repos.artist_repo.transaction do
            artist.all_associated_artists.each do |a|
              @sequel_repos.artist_repo.store(a)
            end
            artist.all_genres.each do |g|
              @sequel_repos.genre_repo.store(g)
            end
            @sequel_repos.artist_repo.store(artist)
          end
        rescue => e
          failures << [artist, e]
        end

        successes << artist
      end

      {:successes => successes, :failures => failures}
    end
  end
end
