# encoding: utf-8

require 'curses'
require_relative 'constants'
require_relative 'commands_window'
require_relative 'menu_bar'
require_relative 'items_window'

Curses.curs_set(0)
Curses.noecho # do not show typed chars
Curses.nonl # turn off newline translation
Curses.stdscr.keypad(true) # enable arrow keys
Curses.raw # give us all other keys
Curses.stdscr.nodelay = 1 # do not block -> we can use timeouts
Curses.init_screen
Curses.start_color

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
  when "\e".ord
    items_window.step_up_one_menu_level
  end
end

menu_bar.close
items_window.close
commands_window.close