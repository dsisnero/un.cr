# src/un.cr
module UN
  VERSION = "0.3.0"

  def self.help(argv : Array, output : IO = STDOUT)
    all = argv.empty?
    cmd = nil
    messages = {} of String => String
    store = ->(msg : String) { messages[cmd] = msg }

    File.open(__FILE__) do |me|
      while me.gets("##\n")
        if help = me.gets("\n\n")
          if all || argv.includes?(cmd = help[/^#\s*ruby\s.*-e\s+(\w+)/, 1])
            store[help.gsub(/^# ?/, "")]
            break unless all || argv.size > messages.size
          end
        end
      end
    end

    if !messages.empty?
      argv.each { |arg| output.puts(messages[arg]) }
    end
  end
end

# Colorize ruby code.
def colorize
  begin
    require "irb/color"
  rescue load_error
    raise "colorize requires irb 1.1.0 or later"
  end
  setup do |argv, _|
    if argv.empty?
      puts IRB::Color.colorize_code(STDIN.read)
      return
    end
    argv.each do |file|
      puts IRB::Color.colorize_code(File.read(file))
    end
  end
end

# Display help message.
def help
  setup do |argv, _|
    UN.help(argv)
  end
end
