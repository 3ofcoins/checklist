require 'highline'

module Checklist
  class UI
    attr_reader :highline

    def initialize(opts = {})
      opts[:in] ||= $stdin
      opts[:out] ||= $stdout
      @highline = HighLine.new(opts[:in], opts[:out])
    end

    def yes_or_no(question)
      highline.yes_or_no("#{question} (yes/no) ")
    end
  end
end
