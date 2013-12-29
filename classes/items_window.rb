# encoding: utf-8

class ItemsWindow
  attr_accessor :window, :selected_line

  WINDOW_HEIGHT = 18
  ITEM_LINES    = WINDOW_HEIGHT - 4

  def initialize
    @window = Curses::Window.new(WINDOW_HEIGHT, Constants::SCREEN_WIDTH, 1, 0)
    @window.scrollok(1)
    @window.idlok(1)
    @window.setscrreg(30, 30)
    @window.box('|', '-')
    @window.keypad(true)
    @selected_line        = 0
    @items                = {
        'Antivirus Applications' => ['Avast Antivirus', 'AVG Free Edition', 'AVG Internet Security Edition',
                                     'Avira Antivir'],
        'Antivirus Removers'     => ['McAfee Removal Tool', 'McAfee Removal Tool v2', 'McAfee Virtual Technician',
                                     'Norton Removal Tool', 'Verizon Internet Security Suite Removal Tool'],
        'Cleanup Tools'          => ['ATF-Cleaner', 'Blastemp', 'CleanUp!'],
        'Spyware/Virus Scanners' => ['AIMFix', 'ComboFix', 'DoctorWeb CureIt!', 'GMER', 'HijackThis',
                                     'MalwareBytes Malware Scan', 'MBR', 'SDFix', 'Spybot Search & Destroy',
                                     'SUPERAntiSpyware'],
        'System Tools'           => ['Dial-a-Fix', 'FileASSASSIN', 'Killbox', 'Unlocker']
    }
    @current_category     = :main
    @top_line_scrolled_to = 0
  end

  def build_items(cropped = true)
    if cropped
      @current_category == :main ?
          @items.keys.slice(@top_line_scrolled_to, ITEM_LINES) :
          @items[@current_category].slice(@top_line_scrolled_to, ITEM_LINES)
    else
      @current_category == :main ? @items.keys : @items[@current_category]
    end
  end

  def build_display
    @window.clear
    @window.box('|', '-')

    build_items.each_with_index do |item, index|
      @window.setpos(2 + index, 3)

      if index == @selected_line
        @window.standout
        @window << item.slice(0, Constants::SCREEN_WIDTH - 4)
        @window.standend
      else
        @window << item.slice(0, Constants::SCREEN_WIDTH - 4)
      end
    end

    @window.setpos(2 + @selected_line, 3)

    @window.refresh
  end

  def method_missing(m, *args)
    @window.send(m, *args)
  end

  def change_selection(d)
    case d
    when :up
      unless @selected_line == 0 and @top_line_scrolled_to == 0
        @top_line_scrolled_to -= 1 if @selected_line == 0
        @selected_line        -= 1 unless @selected_line == 0
      end
    when :down
      unless (@top_line_scrolled_to + @selected_line + 1) == build_items(false).count
        @top_line_scrolled_to += 1 if @selected_line == ITEM_LINES - 1
        @selected_line        += 1 unless @selected_line == ITEM_LINES - 1
      end
    end
    @window.setpos(2 + @selected_line, 3)

    build_display
  end

  def select_item
    @current_category = build_items(false)[@selected_line + @top_line_scrolled_to]
    @selected_line    = 0
    build_display
  end

  def step_up_one_menu_level
    unless @current_category == :main
      @current_category = :main
      @selected_line    = 0
      build_display
    end
  end
end
