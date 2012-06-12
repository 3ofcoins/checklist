require 'formatador'

class Checklist
  class UI
    def initialize
      @fmtd = Formatador.new
    end

    def say(msg='')
      fmtd.display "#{msg}\n"
    end

    def header(checklist)
      fmtd.display "[bold][yellow]CHECKLIST[/][yellow]:[/] [bold]#{checklist.name}[/]\n"
    end

    def start(step)
      fmtd.display "[ ] [yellow]#{step.challenge}[/] ..."
    end

    def finish(step)
      fmtd.redisplay "[[green][bold]+[/]] #{step.challenge} [green]#{step.response}[/]\n"
    end

    def complete(checklist)
      fmtd.display "[green]All #{checklist.length} steps [bold]completed[/]\n"
    end

    def incomplete(checklist, remaining_steps)
      fmtd.redisplay "[[bold][red]X[/]] #{checklist.current.challenge} [red]FAILED[/]\n"
      fmtd.display "[red]#{checklist.remaining}/#{checklist.length} STEPS [bold]NOT COMPLETED[/] [bold]:[/]\n"

      fmtd.display_table(
        remaining_steps.map(&:to_hash), %w(Challenge Response Description))
    end

    private
    attr_reader :fmtd
  end
end
