# encoding: utf-8

require 'curses'
require_relative 'classes/constants'
require_relative 'classes/menu_bar'
require_relative 'classes/commands_window'
require_relative 'classes/items_window'
require_relative 'classes/download_window'
require_relative 'classes/item'
require_relative 'classes/progress_bar'

Curses.curs_set(0)
Curses.noecho # do not show typed chars
Curses.nonl # turn off newline translation
Curses.stdscr.keypad(true) # enable arrow keys
Curses.raw # give us all other keys
Curses.stdscr.nodelay = 1 # do not block -> we can use timeouts
Curses.init_screen
Curses.start_color
Curses.init_pair(1, Curses::COLOR_GREEN, Curses::COLOR_BLACK)
Curses.init_pair(2, Curses::COLOR_BLACK, Curses::COLOR_GREEN)
Curses.init_pair(3, Curses::COLOR_BLACK, Curses::COLOR_WHITE)

menu_bar = MenuBar.new
menu_bar.build_display
commands_window = CommandsWindow.new
commands_window.build_display
items_window = ItemsWindow.new
items_window.build_display

until (key = items_window.getch) == 'q'
  case key
  when Curses::Key::UP
    items_window.change_selection(:up)
  when Curses::Key::DOWN
    items_window.change_selection(:down)
  when "\r".ord
    items_window.select_item
  when "\t".ord
    items_window.step_up_one_menu_level
  end
end

menu_bar.close
items_window.close
commands_window.close
