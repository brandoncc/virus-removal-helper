class Item
  attr_accessor :executable_name, :category, :title, :download_url

  def initialize(title, category, download_url = nil)
    @title        = title
    self.category = category
    set_executable_name(title)
    @download_url  = download_url
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

  def normalized_category_folder
    mapped_branches = self.category.split('|').map do |branch|
      branch.gsub(/[^A-Za-z0-9]/, '_').gsub(/_{2,}/, '_')
    end

    mapped_branches.join(File::SEPARATOR)
  end

  def get_download_link

  end

  def download_file(parent_window)
    if @download_url.is_a?(Array)
      url = get_download_link
    else
      url = self.download_url
    end

    download_window = DownloadWindow.new(self, parent_window)
    download_window.build_display
    download_window.download_file(self.download_url)
  end
end
