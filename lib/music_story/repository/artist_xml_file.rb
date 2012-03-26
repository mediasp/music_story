module MusicStory
  # Parses an XML file of MusicStory artiste objects.
  # The top-level structure should be
  # <items>...<artistes><artist>...</artist>...<artist>...</artist></artistes></items>.
  #
  # A formal XSD doesn't appear to exist, so this is based entirely on data seen so far,
  # together with some small pieces of info (such as the ARTIST_GENRE_RELATIONS and
  # ASSOCIATION_TYPES) gleaned from a brief PDF doc in franglais (descriptionxml_en.pdf).
  #
  # Some elements mentioned in the PDF (such as collaboration, album, evenement etc)
  # haven't been seen so far in artist XML files so aren't handled.
  class Repository::ArtistXMLFile
    def initialize(io)
      @reader = Nokogiri::XML::Reader.from_io(io)
    end
    
    def self.new_with_open_file(filename, &block)
      File.open(filename, 'r') do |file|
        yield new(file)
      end
    end
    
    # Codes used in their XML file format:
    ARTIST_GENRE_RELATIONS = {
      1 => :main,
      2 => :secondary,
      3 => :influenced_by
    }
    
    ASSOCIATION_TYPES = {
      'A' => :similar,
      'I' => :influenced_by,
      'S' => :successor
    }
    
    include Enumerable
    def get_all; self; end
    
    def each
      @reader.each do |node|
        next unless node.name == 'artiste' && node.node_type == Nokogiri::XML::Reader::TYPE_ELEMENT
        doc = Nokogiri::XML(node.outer_xml)
        
        genre_relations = doc.xpath('//artiste/genres/genre').map do |node|
          [
            ARTIST_GENRE_RELATIONS[node.attr('relation').to_i],
            Model::Genre.new(
              :id   => node.attr('id').to_i,
              :name => node.inner_text.strip
            )
          ]
        end
        
        associations = doc.xpath('//artiste/associes/associe').map do |node|
          [
            ASSOCIATION_TYPES[node.inner_text],
            Model::Artist.new({
              :id => node.attr('id_associe').to_i,
              :name => node.attr('nom_associe')
            })
          ]
        end
        
        yield Model::Artist.new({
          :id       => doc.xpath('//artiste').attr('id').value.to_i,
          :name     => doc.xpath('//artiste/nom').inner_text,
          :forename => unless_empty(doc.xpath('//artiste/prenom').inner_text),
          :real_name => unless_empty(doc.xpath('//artiste/nom_reel').inner_text),
          :role     => unless_empty(doc.xpath('//artiste/role').inner_text),
          :type     => unless_empty(doc.xpath('//artiste/type').inner_text),
          :country  => unless_empty(doc.xpath('//artiste/pays').inner_text),
          # not sure what the appropriate translation for resume vs texte_bio is here,
          # but in data seen so far they are both the same and both HTML not plain text:
          :summary_html => unless_empty(doc.xpath('//artiste/resume').inner_text),
          :bio_html => unless_empty(doc.xpath('//artiste/texte_bio').inner_text),
          :genre_relations => genre_relations,
          :associations => associations
        })
      end
    end

  private
    def unless_empty(string)
      string = string.strip
      string unless string.empty?
    end
  end
end
