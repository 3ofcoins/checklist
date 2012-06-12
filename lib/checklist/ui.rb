class Checklist
  class UI
    def say(msg='')
      puts msg
    end

    def header(checklist)
      say "*** #{checklist.name} ***"
    end

    def start(step)
      say "** #{step.challenge} .."
    end

    def finish(step)
      say "** #{step.challenge} #{step.response}"
    end

    def complete(checklist)
      say "*** All #{checklist.length} steps completed ***"
    end

    def incomplete(checklist)
      say "*** #{checklist.remaining}/#{checklist.length} STEPS NOT COMPLETED ***"
    end

    def describe(step)
      say "** #{step.challenge} (#{step.response})"
      say step.description if step.description
      say
    end
  end
end
