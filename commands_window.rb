# encoding: utf-8

class CommandsWindow
  attr_accessor :window

  WINDOW_HEIGHT = 4

  def initialize
    @window = Curses::Window.new(WINDOW_HEIGHT, Constants::SCREEN_WIDTH, 20, 0)
    @window.box('|', '-')
  end

  def build_display
    commands = ['[enter] - Select / Download and Execute', '[e] - Execute only',
                '[esc-esc] - Up one level', '[c] - Cleanup', '[t] - Fix time format', '[q] - Quit']

    command_string ||= ''
    commands.each do |c|
      last_line = if command_string.split("\n").last.nil?
                    command_string
                  else
                    command_string.split("\n").last
                  end

      if last_line.length + c.length > Constants::SCREEN_WIDTH - 3
        command_string << "\n"
        command_string << "#{c}"
      else
        if last_line.length == 0
          command_string << "#{c}"
        else
          command_string << " #{c}"
        end
      end
    end

    command_string.split("\n").each_with_index do |l, i|
      @window.setpos(1+i, 2)
      @window << l.center(Constants::SCREEN_WIDTH - 4)
    end

    @window.refresh
  end

  def method_missing(m, *args)
    @window.send(m, *args)
  end
end
