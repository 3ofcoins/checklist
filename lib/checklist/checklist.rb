require 'forwardable'

require_relative './locals'
require_relative './step'
require_relative './template_cache_mixin'
require_relative './ui'

module Checklist
  class Checklist
    class Context
      def initialize(locals = nil)
        locals.infest(self) if locals
      end
    end

    extend TemplateCacheMixin
    extend Forwardable

    attr_reader :name, :locals, :steps, :ui
    def_delegator :locals, :let

    def initialize(name, opts = {}, &block)
      @name = name
      @ui = opts.fetch(:ui) { UI.new(opts) }
      @locals = Locals.new
      @steps = []
      @opts = opts
      raise ArgumentError, 'Block is required' unless block_given?
      instance_exec(self, &block)
      steps.freeze
      locals.freeze
    end

    def step(name, *args, &block)
      add_step(Step, name, *args, &block)
    end

    def checklist(name, *args, &block)
      add_step(Checklist, name, *args, &block)
    end

    def run!(_=nil)
      ctx = Context.new(locals)
      report_header
      steps.each do |st|
        ui.say
        st.run!(ctx)
      end
    rescue => err
      ui.say Rainbow("\nFAILED:").bright.red,
             Rainbow(name).underline
      ui.say Rainbow('EXCEPTION:').red,
             err
      ui.say Rainbow('REMAINING STEPS:').yellow
      steps.reject(&:done?).each(&:report)
      raise
    else
      ui.say Rainbow("\nFINISHED:").bright.green,
             Rainbow(name).underline
    end

    def report_header
      ui.say @opts[:number] && Rainbow("##{@opts[:number]}.").white.bright,
             Rainbow('CHECKLIST:').bright.yellow,
             Rainbow(name).underline
    end

    def report
      report_header
      steps.each(&:report) unless @opts[:compact]
    end

    def done?
      steps.all?(&:done?)
    end

    def length
      steps.length
    end

    private

    def add_step(klass, name, *args, &block)
      opts = args.last.is_a?(Hash) ? args.pop : {}
      opts[:ui] = ui
      opts[:number] = [@opts[:number], (steps.length + 1).to_s].compact.join('.')
      if block_given?
        opts[:args] = args unless args.empty?
        steps << klass.new(name, opts, &block)
      else
        steps << klass.render_template(name, opts, *args)
      end
    end
  end
end
