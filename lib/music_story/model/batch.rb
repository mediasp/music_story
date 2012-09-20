module MusicStory::Model
  class Batch < ThinModels::Struct
    attribute :path
    attribute :state

    DATE_PATTERN = /([0-9]{4})\-([0-9]{2})\-([0-9]{2})/

    def date
      m = DATE_PATTERN.match(File.basename(path))
      m && Date.new(m[1].to_i, m[2].to_i, m[3].to_i)
    end

    def to_s
      "#<Batch path=#{path}>"
    end

    def ==(rhs)
      rhs && rhs.is_a?(Batch) && rhs.path == self.path
    end
  end
end
