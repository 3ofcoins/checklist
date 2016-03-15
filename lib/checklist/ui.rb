require 'highline'
require 'locale'
require 'rainbow'

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

    def utf8?
      Locale.charset == 'UTF-8'
    end
  end
end
