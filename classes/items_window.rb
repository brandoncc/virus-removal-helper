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

    [
        ['Avast Antivirus', 'http://files.avast.com/iavs9x/avast_free_antivirus_setup.exe', :direct],
        ['AVG Free Edition', 'http://files.avast.com/iavs9x/avast_free_antivirus_setup.exe', :direct],
        ['AVG Internet Security Edition', 'http://files.avast.com/iavs9x/avast_free_antivirus_setup.exe', :direct],
        ['Avira Antivir', 'http://files.avast.com/iavs9x/avast_free_antivirus_setup.exe', :direct]
    ].each do |i|
      @items << Item.new(i[0], 'Antivirus Applications', i[1], i[2])
    end

    [
        ['McAfee Removal Tool', 'http://download.mcafee.com/products/licensed/cust_support_patches/MCPR.exe', :direct],
        ['McAfee Removal Tool v2', 'http://download.mcafee.com/products/licensed/cust_support_patches/MCPR.exe', :direct],
        ['McAfee Virtual Technician', 'http://download.mcafee.com/products/licensed/cust_support_patches/MCPR.exe', :direct],
        ['Norton Removal Tool', 'http://download.mcafee.com/products/licensed/cust_support_patches/MCPR.exe', :direct],
        ['Verizon Internet Security Suite Removal Tool', 'http://download.mcafee.com/products/licensed/cust_support_patches/MCPR.exe', :direct]
    ].each do |i|
      @items << Item.new(i[0], 'Antivirus Removers', i[1], i[2])
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
          matching_items << "#{i.title}" unless matching_items.include?(i.title)
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
        @window << item.slice(0, Constants::SCREEN_WIDTH - 6)
        @window.standend
      else
        @window << item.slice(0, Constants::SCREEN_WIDTH - 6)
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

  def get_selected_item
    @items.select{ |i| self.items(false)[@selected_line + @top_line_scrolled_to] == i.title }.first
  end


  def select_item
    if @current_category == :main
      @current_category = self.items(false)[@selected_line + @top_line_scrolled_to]
      @selected_line    = 0
      build_display
    else
      get_selected_item.download_file(self)
    end
  end

  def step_up_one_menu_level
    unless @current_category == :main
      @current_category = :main
      @selected_line    = 0
      build_display
    end
  end

  def quick_navigate_to(character)
    navigation_index = get_index_by_character(character)

    unless navigation_index.nil?
      set_selected_index_for_quick_navigation(navigation_index)
    end

    build_display
  end

  def set_selected_index_for_quick_navigation(index)
    total_items_count = items(false).count
    if total_items_count <= ITEM_LINES
      @selected_line        = index
      @top_line_scrolled_to = 0
    else
      if total_items_count - index <= ITEM_LINES
        @top_line_scrolled_to = total_items_count - ITEM_LINES
        @selected_line        = index - @top_line_scrolled_to
      else
        @top_line_scrolled_to = index
        @selected_line        = 0
      end
    end
  end

  def get_index_by_character(character)
    character = character.downcase

    all_items        = self.items(false)
    navigation_index = nil

    all_items.each_with_index do |item, index|
      if item[0].downcase >= character.downcase
        navigation_index = index
        break
      end
    end

    navigation_index
  end
end
