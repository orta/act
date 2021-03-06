require 'colored'
require 'active_support/core_ext/string/strip'
require 'open3'

module Act
  module Helper
    # @return [String]
    #
    def self.open_in_editor_command(path, line)
      editor = ENV['EDITOR']
      result = "#{editor} #{path}"
      if line
        case editor
        when 'vim', 'mvim'
          result = "#{editor} #{path} +#{line}"
        end
      end
      result
    end

    # @return [Fixnum]
    #
    def self.start_line(string, line, context_lines)
      start_line = line - context_lines - 1
    end

    # @return [Fixnum]
    #
    def self.end_line(string, line, context_lines)
      end_line = line + context_lines - 1
    end

    # @return [String, Nil]
    #
    def self.select_lines(string, start_line, end_line)
      start_line = start_line - 1
      end_line = end_line - 1
      start_line = 0 if start_line < 0
      end_line = 0 if end_line < 0
      components = string.lines[start_line..end_line]
      components.join if components && !components.empty?
    end

    # @return [String]
    #
    def self.strip_indentation(string)
      string.strip_heredoc
    end

    # @return [String]
    #
    def self.add_line_numbers(string, start_line, highlight_line = nil)
      start_line ||= 1
      line_count = start_line
      numbered_lines = string.lines.map do |line|
        number = line_count.to_s.ljust(3)
        if highlight_line && highlight_line == line_count
          number = number.yellow
        end
        line_count += 1
        "#{number}  #{line}"
      end
      numbered_lines.join
    end

    # @return [String]
    #
    def self.syntax_highlith(string, file_name)
      return string if `which gen_bridge_metadata`.strip.empty?
      result = nil
      lexer = lexer(file_name)
      Open3.popen3("pygmentize -l #{lexer}") do |stdin, stdout, stderr|
        stdin.write(string)
        stdin.close_write
        result = stdout.read
      end
      result
    end

    def self.lexer(file_name)
      lexer = `pygmentize -N #{file_name}`.chomp
      if lexer == 'text'
        lexer = case file_name
        when 'Gemfile', 'Rakefile', 'Podfile'
          'rb'
        when 'Podfile.lock', 'Gemfile.lock'
          'yaml'
        end
      end
      lexer
    end
  end
end
