require 'highline'
require 'locale'

begin
  # silence warnings
  orig_verbose = $VERBOSE
  $VERBOSE = nil
  require 'rainbow'
ensure
  $VERBOSE = orig_verbose
end

module Checklist
  class UI
    attr_reader :highline, :input, :output

    def initialize(opts = {})
      @input = opts.fetch(:in, $stdin)
      @output = opts.fetch(:out, $stdout)
      @highline = HighLine.new(input, output)
    end

    def yes_or_no(question)
      highline.yes_or_no("#{question} (yes/no) ")
    end

    def say(*phrase)
      output.puts(phrase.compact.join(' ') << "\n")
    end

    UnicodeDWIM = Struct.new(:unicode, :ascii) do
      def to_s
        if Locale.charset == 'UTF-8'
          unicode.to_s
        else
          ascii.to_s
        end
      end
    end
  end
end
