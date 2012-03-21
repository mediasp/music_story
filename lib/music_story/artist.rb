module MusicStory
  class Artist
    def initialize(attributes)
      attributes.each {|k,v| instance_variable_set(:"@#{k}", v)}
    end
    
    attr_accessor :id # MusicStory identifier
    attr_accessor :name, :forename, :real_name # nom (full name), prenom, nom_reel
    attr_accessor :role, :type, :country # role, type, pays

    # Called 'resume' and 'texte_bio' in the MusicStory XML.
    # Not sure what the appropriate translation for resume vs texte_bio is here,
    # but in data seen so far they are both the same except that texte_bio has a
    # credit/copyright line added at the end. Both are given as html, not plain
    # text. (But see plain_text_{bio,summary})
    attr_accessor :summary_html, :bio_html
    
    attr_accessor :genre_relations # array of [relation_type, Genre]
    attr_accessor :associations    # array of [association_type, Artist]

    ARTIST_GENRE_RELATIONS = {
      1 => :main,
      2 => :secondary,
      3 => :influenced_by
    }
    
    def main_genres
      @genre_relations.select {|type,genre| type == :main}.map {|type,genre| genre}
    end
    
    def secondary_genres
      @genre_relations.select {|type,genre| type == :secondary}.map {|type,genre| genre}
    end
    
    def influenced_by_genres
      @genre_relations.select {|type,genre| type == :influenced_by}.map {|type,genre| genre}
    end
    
    def all_genres
      @genre_relations.map {|type,genre| genre}
    end
    
    ASSOCIATION_TYPES = {
      'A' => :similar,
      'I' => :influenced_by,
      'S' => :successor
    }
    
    def similar_artists
      @associations.select {|type,artist| type == :similar}.map {|type,artist| artist}
    end
    
    def influenced_by_artists
      @associations.select {|type,artist| type == :influenced_by}.map {|type,artist| artist}
    end
    
    # 'successor' was MusicStory's English translation, appears to mean 'is succeeded by'
    # or perhaps more accurately 'influenced' / 'was followed by'. From their example sounds
    # like it's similar semantics to 'influenced by' but in the opposite direction:
    #
    # <associe id_artiste="3795" id_associe="454" nom_associe="Michael Jackson">S</associe>
    # "id_artist 3795 is Diana Ross et id_associe 454 is Michael Jackson.
    # The relation means that Micheal Jackson is a successor of Diana Ross.
    # The reverse isn't not always true, Michael Jackson will not necessarily be mentioned
    # as influenced by Diana Ross"
    def successor_artists
      @associations.select {|type,artist| type == :successor}.map {|type,artist| artist}
    end
    
    def all_associated_artists
      @associations.map {|type,artist| artist}
    end
    
    # The bio html converted to plain text, see HTMLToText
    def plain_text_bio
      bio_html && HTMLToText.convert(bio_html)
    end

    # The summary html converted to plain text, see HTMLToText
    def plain_text_summary
      summary_html && HTMLToText.convert(summary_html)
    end
  end
end