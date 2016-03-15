require 'forwardable'

require_relative './locals'
require_relative './step'
require_relative './ui'

module Checklist
  class Checklist
    class Context
      def initialize(locals = nil)
        locals.infest(self) if locals
      end
    end

    extend Forwardable

    attr_reader :name, :locals, :steps, :ui
    def_delegator :locals, :let

    def initialize(name, opts = {}, &block)
      @name = name
      @ui = opts.fetch(:ui) { UI.new(opts) }
      @locals = Locals.new
      @steps = []
      raise ArgumentError, 'Block is required' unless block_given?
      instance_exec(self, &block)
      steps.freeze
      locals.freeze
    end

    def step(name, opts = {}, &block)
      steps << Step.new(
        name,
        opts.merge(ui: ui, number: steps.length + 1),
        &block)
    end

    def run!
      ctx = Context.new(locals)
      report_header
      steps.each do |st|
        ui.say
        st.run!(ctx)
      end
    rescue => e
      ui.say Rainbow("\nFATAL:").bright.red,
             Rainbow(e.to_s).underline
      ui.say Rainbow('REMAINING STEPS:').yellow
      steps.reject(&:done?).each(&:report)
      raise
    end

    def report_header
      ui.say Rainbow('CHECKLIST:').bright.yellow,
             Rainbow(name).underline
    end

    def report
      report_header
      steps.each(&:report)
    end
  end
end
