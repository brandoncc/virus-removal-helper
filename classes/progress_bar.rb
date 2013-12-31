class ProgressBar
  def initialize(total_size, width)
    @total_size = total_size
    @width      = width
    @start_time = Time.now
  end

  def show(current_file_size)
    download_speed    = humanize_speed(current_file_size)
    progress_in_units = humanize_size(current_file_size)

    bar = build_bar(current_file_size, @width - download_speed.length - progress_in_units.length - 6)

    "#{bar}  #{download_speed}  #{progress_in_units}"
  end

  private

  def build_bar(c, width, completed_char = '#', pad_char = '-')
    completion_percentage = (c / Float(@total_size)).round(3)
    inner_bar_size        = width - 3 - completion_percentage

    inner_bar = ''
    inner_bar << completed_char * (inner_bar_size * completion_percentage).ceil
    inner_bar << pad_char * (inner_bar_size - inner_bar.length)

    "[#{inner_bar}] #{(completion_percentage * 100).round.to_s.length == 1 ? ' ' +
        (completion_percentage * 100).round.to_s :
        (completion_percentage * 100).round}%"
  end

  def humanize_size(size)
    total_file_size_text = if @total_size >= 1024 * 1024 * 1024 * 1024
                             "#{(@total_size / (1024.0 * 1024 * 1024 * 1024)).round(2)}TB"
                           elsif @total_size >= 1024 * 1024 * 1024
                             "#{(@total_size / (1024.0 * 1024 * 1024)).round(2)}GB"
                           elsif @total_size >= 1024 * 1024
                             "#{(@total_size / (1024.0 * 1024)).round(2)}MB"
                           elsif @total_size >= 1024
                             "#{(@total_size / (1024.0)).round(2)}KB"
                           else
                             "#{@total_size}B"
                           end

    current_file_size_text = if @total_size >= 1024 * 1024 * 1024 * 1024
                               "#{(size / (1024.0 * 1024 * 1024 * 1024)).round(2)}TB"
                             elsif @total_size >= 1024 * 1024 * 1024
                               "#{(size / (1024.0 * 1024 * 1024)).round(2)}GB"
                             elsif @total_size >= 1024 * 1024
                               "#{(size / (1024.0 * 1024)).round(2)}MB"
                             elsif @total_size >= 1024
                               "#{(size / (1024.0)).round(2)}KB"
                             else
                               "#{size}B"
                             end

    if total_file_size_text.length - current_file_size_text.length >= 0
      current_file_size_text = (' ' * (total_file_size_text.length - current_file_size_text.length)) +
          current_file_size_text
      "#{current_file_size_text} / #{total_file_size_text}"
    else
      ''
    end
  end

  def humanize_speed(c)
    speed = c / (Time.now - @start_time)

    if speed >= 1024 * 1024 * 1024 * 1024
      "#{(speed / (1024 * 1024 * 1024 * 1024)).round(2)} TB/s"
    elsif speed >= 1024 * 1024 * 1024
      "#{(speed / (1024 * 1024 * 1024)).round(2)} GB/s"
    elsif speed >= 1024 * 1024
      "#{(speed / (1024 * 1024)).round(2)} MB/s"
    elsif speed >= 1024
      "#{(speed / (1024)).ceil} KB/s"
    else
      "#{speed} B/s"
    end
  end
end
