module MusicStory
  class Model::Genre < ThinModels::Struct
    identity_attribute :id # MusicStory identifier
    attribute :name
    alias :to_s :name
  end
end