# encoding: utf-8

class ItemsWindow
  attr_accessor :window, :selected_line

  WINDOW_HEIGHT = 18
  ITEM_LINES    = WINDOW_HEIGHT - 4

  def initialize
    @window = Curses::Window.new(WINDOW_HEIGHT, Constants::SCREEN_WIDTH, 1, 0)
    @window.box('|', '-')
    @window.keypad(true)
    @selected_line        = 0
    @current_category     = :main
    @top_line_scrolled_to = 0
    build_items
  end

  def build_items
    @items = []

    ['Avast Antivirus', 'AVG Free Edition', 'AVG Internet Security Edition', 'Avira Antivir'].each do |i|
      @items << Item.new(i, 'Antivirus Applications')
    end

    ['McAfee Removal Tool', 'McAfee Removal Tool v2', 'McAfee Virtual Technician', 'Norton Removal Tool',
     'Verizon Internet Security Suite Removal Tool'].each do |i|
      @items << Item.new(i, 'Antivirus Removers')
    end

    ['ATF-Cleaner', 'Blastemp', 'CleanUp!'].each do |i|
      @items << Item.new(i, 'Cleanup Tools')
    end

    ['AIMFix', 'ComboFix', 'DoctorWeb CureIt!', 'GMER', 'HijackThis', 'MalwareBytes Malware Scan', 'MBR', 'SDFix',
     'Spybot Search & Destroy', 'SUPERAntiSpyware'].each do |i|
      @items << Item.new(i, 'Spyware/Virus Scanners')
    end

    ['Dial-a-Fix', 'FileASSASSIN', 'Killbox', 'Unlocker'].each do |i|
      @items << Item.new(i, 'System Tools')
    end
  end

  def items(cropped = true)
    matching_items = []

    case @current_category
    when :main
      @items.each do |i|
        root_category = i.category.split('|').first

        matching_items << root_category unless matching_items.include?(root_category)
      end
    else
      @items.each do |i|
        if i.category == @current_category
          matching_items << "#{i.title} (#{i.executable_name})" unless matching_items.include?(i.title)
        end
      end
    end

    if cropped
      matching_items.slice(@top_line_scrolled_to, ITEM_LINES)
    else
      matching_items
    end
  end

  def build_display
    @window.clear
    @window.box('|', '-')

    self.items.each_with_index do |item, index|
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
      unless (@top_line_scrolled_to + @selected_line + 1) == self.items(false).count
        @top_line_scrolled_to += 1 if @selected_line == ITEM_LINES - 1
        @selected_line        += 1 unless @selected_line == ITEM_LINES - 1
      end
    end
    @window.setpos(2 + @selected_line, 3)

    build_display
  end

  def select_item
    @current_category = self.items(false)[@selected_line + @top_line_scrolled_to]
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
