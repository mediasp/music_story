module MusicStory
  # Converts HTML to plain text, converting <br>'s into newlines but
  # stripping all other tags.
  # May want to add support for other things like <p> into \n\n if they
  # crop up; MusicStory only seems to use <br> though
  class Utils::HTMLToText < Nokogiri::XML::SAX::Document
    def self.convert(html)
      doc = new
      Nokogiri::HTML::SAX::Parser.new(doc).parse(html)
      doc.to_s
    end
    
    def initialize
      @result = ''
    end
    
    def characters(string)
      @result << string
    end
    alias :cdata_block :characters
    
    def start_element(name, attributes=nil)
      @result << "\n" if name.downcase == 'br'
    end
    
    def to_s
      @result.strip
    end
  end
end