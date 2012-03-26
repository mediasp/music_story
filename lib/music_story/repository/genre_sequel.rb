module MusicStory
  class Repository::GenreSequel < Persistence::Sequel::IdentitySetRepository
    set_model_class Model::Genre
    use_table :genres, :id_sequence => true
    map_column :name
  end
end