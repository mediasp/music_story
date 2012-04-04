module MusicStory
  class Repository::ArtistSequel < Persistence::Sequel::IdentitySetRepository
    set_model_class Model::Artist
    use_table :artists, :id_sequence => true
    map_column :name
    map_column :forename
    map_column :real_name
    map_column :role
    map_column :type
    map_column :country
    map_column :summary_html
    map_column :image_filename
    map_column :bio_html

    [:similar, :influenced_by, :successor].each do |rel|
      map_many_to_many :"#{rel}_artists",
        :model_class => Model::Artist,
        :join_table  => :artist_associations,
        :filter      => {:relation => rel.to_s},
        :left_key    => :from_artist_id,
        :right_key   => :to_artist_id,
        :writeable   => true
    end

    [:main, :secondary, :influenced_by].each do |rel|
      map_many_to_many :"#{rel}_genres",
        :model_class => Model::Genre,
        :join_table  => :artist_genres,
        :filter      => {:relation => rel.to_s},
        :left_key    => :artist_id,
        :right_key   => :genre_id,
        :writeable   => true
    end
  end
end
