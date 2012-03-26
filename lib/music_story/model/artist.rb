module MusicStory
  class Model::Artist < ThinModels::Struct
    identity_attribute :id # MusicStory identifier
    attribute :name        # 'nom' at source
    attribute :forename    # 'prenom' at source
    attribute :real_name   # 'nom_reel' at source
    attribute :role
    attribute :type
    attribute :country     # 'pays' at source

    # Called 'resume' and 'texte_bio' in the MusicStory XML.
    # Not sure what the appropriate translation for resume vs texte_bio is here,
    # but in data seen so far they are both the same except that texte_bio has a
    # credit/copyright line added at the end. Both are given as html, not plain
    # text. (But see plain_text_{bio,summary})
    attribute :summary_html
    attribute :bio_html
    
    attribute :main_genres
    attribute :secondary_genres
    attribute :influenced_by_genres
    def all_genres
      (main_genres + secondary_genres + influenced_by_genres).uniq
    end
    
    attribute :similar_artists
    attribute :influenced_by_artists
    
    # 'successor' was MusicStory's English translation, appears to mean 'is succeeded by'
    # or perhaps more accurately 'influenced' / 'was followed by'. From their example sounds
    # like it's similar semantics to 'influenced by' but in the opposite direction:
    #
    # <associe id_artiste="3795" id_associe="454" nom_associe="Michael Jackson">S</associe>
    # "id_artist 3795 is Diana Ross et id_associe 454 is Michael Jackson.
    # The relation means that Micheal Jackson is a successor of Diana Ross.
    # The reverse isn't not always true, Michael Jackson will not necessarily be mentioned
    # as influenced by Diana Ross"
    attribute :successor_artists
    
    def all_associated_artists
      (similar_artists + influenced_by_artists + successor_artists).uniq
    end
    
    # The bio html converted to plain text, see HTMLToText
    def plain_text_bio
      bio_html && Utils::HTMLToText.convert(bio_html)
    end

    # The summary html converted to plain text, see HTMLToText
    def plain_text_summary
      summary_html && Utils::HTMLToText.convert(summary_html)
    end
  end
end