# encoding: utf-8

class MenuBar
  attr_accessor :window

  WINDOW_HEIGHT = 1

  def initialize
    @window = Curses::Window.new(WINDOW_HEIGHT, Constants::SCREEN_WIDTH, 0, 0)
    @window.color_set(2)
  end

  def build_display
    @window <<
        "Virus Removal Helper - Copyright 2008-#{Time.new.year} Brandon Conway".center(Constants::SCREEN_WIDTH)
    @window.refresh
  end

  def method_missing(m, *args)
    @window.send(m, *args)
  end
end
