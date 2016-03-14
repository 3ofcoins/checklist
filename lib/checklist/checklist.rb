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
      steps << Step.new(name, opts, &block)
    end

    def run!
      ctx = Context.new(locals)
      ui.show_checklist_header(self)
      steps.each_with_index do |st, i|
        ui.show_step(i + 1, st)
        st.run!(ctx)
      end
    rescue => e
      ui.say "** FATAL: #{e}"
      ui.say 'Remaining steps:'
      steps.each_with_index do |st, i|
        next if st.done?
        ui.show_step(i + 1, st)
      end
      raise
    end
  end
end
