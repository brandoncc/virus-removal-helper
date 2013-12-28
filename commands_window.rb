class CommandsWindow
  attr_accessor :window

  def initialize
    @window = Curses::Window.new(4, 80, 20, 0)
  end

  def display
    commands = ['enter - Select / Download', 'shift + enter - Execute only',
                'esc - Up one level', 'c - Cleanup', 't - Fix time format', 'q - Quit']

    command_string ||= ''
    commands.each do |c|
      last_line = if command_string.split("\n").last.nil?
                    command_string
                  else
                    command_string.split("\n").last
                  end

      if last_line.length + c.length > 75
        command_string << "\n"
        command_string << "[#{c}]"
      else
        if last_line.length == 0
          command_string << "[#{c}]"
        else
          command_string << " [#{c}]"
        end
      end
    end


    @window.box('|', '-')
    command_string.split("\n").each_with_index do |l, i|
      @window.setpos(1+i, 2)
      @window << l.center(76)
    end

    @window.refresh
  end

  def method_missing(m, *args)
    @window.send(m, *args)
  end
end
