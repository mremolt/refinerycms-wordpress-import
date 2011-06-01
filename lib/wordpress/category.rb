module WordPress
  class Category
    attr_accessor :name

    def initialize(text)
      @name = text
    end

    def ==(other)
      name == other.name
    end

    def to_refinery
      BlogCategory.find_or_create_by_title(name)
    end
  end
end
