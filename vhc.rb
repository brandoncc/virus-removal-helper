require 'curses'
require_relative 'commands_window'

Curses.init_screen

commands_window = CommandsWindow.new

commands_window.display

commands_window.getch

commands_window.close
