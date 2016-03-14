# -*- coding: utf-8 -*-
require 'formatador'
require 'locale'

module Checklist
  class UI
    UTF8_MARKS = {
      tick: '✓',
      cross: '✗' }.freeze

    ASCII_MARKS = {
      tick: '[bold]+',
      cross: '[bold]X' }.freeze

    def initialize
      @fmtd = Formatador.new
      @marks = Locale.charset == 'UTF-8' ? UTF8_MARKS : ASCII_MARKS
    end

    def say(msg = '')
      fmtd.display "#{msg}\n"
    end

    def header(checklist)
      fmtd.display "[bold][yellow]CHECKLIST[/][yellow]:[/] [bold]#{checklist.name}[/]\n" # rubocop:disable Metrics/LineLength
    end

    def start(step)
      fmtd.display "  [ ] [yellow]#{step.challenge}[/] ..."
    end

    def finish(step)
      fmtd.redisplay "  [[green]#{marks[:tick]}[/]] #{step.challenge} [green]#{step.response}[/]\n" # rubocop:disable Metrics/LineLength
    end

    def complete(checklist)
      fmtd.display "[green]All #{checklist.length} steps [bold]completed[/]\n"
    end

    def incomplete(checklist, remaining_steps)
      fmtd.redisplay "  [[red]#{marks[:cross]}[/]] #{remaining_steps.first.challenge} [red]FAILED[/]\n" # rubocop:disable Metrics/LineLength
      remaining_steps[1..remaining_steps.length].each do |step|
        fmtd.display "  [ ] #{step.challenge} [yellow]PENDING[/]\n"
      end
      fmtd.display "\n[indent]#{checklist.remaining} of #{checklist.length} steps [red]NOT COMPLETED[/]:\n" # rubocop:disable Metrics/LineLength

      fmtd.indent do
        fmtd.display_table(
          remaining_steps.map(&:to_hash),
          %w(Challenge Response Description))
      end
    end

    private

    attr_reader :fmtd, :marks
  end
end
