module WordPress
  class Tag
    attr_accessor :name

    def initialize(text)
      @name = text
    end

    def ==(other)
      name == other.name
    end

    def to_refinery
      ActsAsTaggableOn::Tag.find_or_create_by_name(name)
    end
    
  end
end
