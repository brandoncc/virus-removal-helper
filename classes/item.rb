class Item
  attr_accessor :executable_name, :category, :title

  def initialize(title, category)
    @title = title
    self.category = category
    set_executable_name(title)
  end

  def category=(path)
    @category = path.split('|')
  end

  def category
    @category.join('|')
  end

  def set_executable_name(title)
    self.executable_name = title.gsub(/[^A-Za-z0-9]/, '_').gsub(/_{2,}/, '_')
  end
end
