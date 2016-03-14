require 'highline'
require 'rainbow'

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

    def say(phrase)
      highline.say(phrase)
    end

    def show_checklist_header(checklist)
      say [
        Rainbow('CHECKLIST:').bright.yellow,
        Rainbow(checklist.name).underline
      ].join(' ')
    end

    def show_step(number, step)
      say [
        Rainbow("Step #{number}.").yellow,
        Rainbow(step.name).underline
      ].join(' ')
    end
  end
end
