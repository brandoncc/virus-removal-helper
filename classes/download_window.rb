# encoding: utf-8
require 'net/http'
require 'uri'

class DownloadWindow
  attr_accessor :window, :progress_bar, :size, :item, :start_time

  WINDOW_HEIGHT = 9
  WINDOW_WIDTH  = 70

  PROGRESSBAR_LOCATION_TOP  = WINDOW_HEIGHT - 5
  PROGRESSBAR_LOCATION_LEFT = 3
  PROGRESSBAR_SIZE_HEIGHT   = 1
  PROGRESSBAR_SIZE_WIDTH    = WINDOW_WIDTH - 6

  def initialize(item, parent_window)
    @window = Curses::Window.new(WINDOW_HEIGHT, WINDOW_WIDTH,
                                 (Constants::SCREEN_HEIGHT - WINDOW_HEIGHT) / 2,
                                 (Constants::SCREEN_WIDTH - WINDOW_WIDTH) / 2)

    @window.nodelay = 1
    @item   = item
    @parent = parent_window
    @window.color_set(3)
  end

  def download_file(url)
    url_base = url.split('/')[2]
    url_path = '/'+url.split('/')[3..-1].join('/')
    @counter = 0

    save_dir = File.expand_path(File.dirname(__FILE__)) + File::SEPARATOR + self.item.normalized_category_folder

    if !File::exist?(save_dir)
      FileUtils.makedirs(save_dir)
    end

    local_file = save_dir + File::SEPARATOR + self.item.executable_name + '.' + strip_file_extension(url_path)

    begin
      Net::HTTP.start(url_base) do |http|
        response = http.request_head(URI.escape(url_path))

        self.size       = response['content-length'].to_i
        self.start_time = Time.now

        self.progress_bar = ProgressBar.new(response['content-length'].to_i, PROGRESSBAR_SIZE_WIDTH)

        File.open(local_file, 'w') { |f|
          download = http.get(URI.escape(url_path)) do |str|
            f.write str
            @counter += str.length
            setpos(PROGRESSBAR_LOCATION_TOP, 1)
            @window << (self.progress_bar.show(@counter)).center(WINDOW_WIDTH - 2)
            @window.refresh

            #begin
              char = @window.getch
              http.finish if char == 'c'
            #rescue
              # ERR was returned because nothing has been typed
            #end
          end
        }
      end
    rescue IOError
      delete_cancelled_download(local_file)
    ensure
      @window.close
      @parent.build_display
    end
  end

  def delete_cancelled_download(file)
    File.delete(file) if File.exists?(file)
  end

  def build_display
    @window.box('|', '-')

    @window.setpos(1, 1)
    @window << "Downloading #{item.title}...".center(WINDOW_WIDTH-2)
    @window.setpos(2, 1)
    @window << '-' * (WINDOW_WIDTH - 2)

    (3..WINDOW_HEIGHT-4).each do |l|
      @window.setpos(l, 1)
      @window << ' ' * (WINDOW_WIDTH - 2)
    end

    @window.setpos(WINDOW_HEIGHT - 3, 1)
    @window << '-' * (WINDOW_WIDTH - 2)
    @window.setpos(WINDOW_HEIGHT - 2, 1)
    @window << '[c] - Cancel download'.center(WINDOW_WIDTH - 2)
    @window.refresh
  end

  private

  def strip_file_name(path)
    path.match(/[^\/]*$/)[0].match(/[^\?]*/)[0]
  end

  def strip_file_extension(path)
    path.match(/[^\/]*$/)[0].match(/[^\?]*/)[0].split('.', 2)[1]
  end

  def method_missing(m, *args)
    @window.send(m, *args)
  end
end
