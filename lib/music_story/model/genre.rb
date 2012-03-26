module MusicStory
  class Model::Genre
    def initialize(attributes)
      attributes.each {|k,v| instance_variable_set(:"@#{k}", v)}
    end
  
    attr_accessor :id, :name
    alias :to_s :name
  end
end