# encoding: utf-8

require 'date'

class MenuBar
  attr_accessor :window

  WINDOW_HEIGHT = 1

  def initialize
    @window = Curses::Window.new(WINDOW_HEIGHT, Constants::SCREEN_WIDTH, 0, 0)
  end

  def build_display
    @window.attron(Curses::A_REVERSE)
    @window <<
        "Virus Removal Helper - Copyright 2008-#{Time.new.year} Brandon Conway".center(Constants::SCREEN_WIDTH)
    @window.refresh
  end

  def method_missing(m, *args)
    @window.send(m, *args)
  end
end
