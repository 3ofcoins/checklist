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
      raise ArgumentError, 'Block is required' unless block_given?
      instance_exec(self, &block)
      steps.freeze
      locals.freeze
    end

    def step(name, *args, &block)
      opts = args.last.is_a?(Hash) ? args.pop : {}
      opts[:ui] = ui
      opts[:number] = steps.length + 1
      if block_given?
        opts[:args] = args unless args.empty?
        steps << Step.new(name, opts, &block)
      else
        steps << Step.render_template(name, opts, *args)
      end
    end

    def run!
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
      ui.say Rainbow('CHECKLIST:').bright.yellow,
             Rainbow(name).underline
    end

    def report
      report_header
      steps.each(&:report)
    end

    def done?
      steps.all?(&:done?)
    end

    def length
      steps.length
    end
  end
end
