require_relative './ui'

module Checklist
  class Step
    attr_reader :name, :ui

    def initialize(name, opts={}, &block)
      @name = name
      @ui = opts.fetch(:ui) { UI.new(opts) }
      instance_exec(self, &block) if block_given?
      @configured = true
      raise "No converge provided" unless @converge
      reset!
    end

    def reset!
      @done = false
    end

    def check(question=nil, &block)
      ensure_not_configured
      unless !question.nil? ^ block_given?
        raise ArgumentError, 'need either a question or a block'
      end
      @check = block || question
    end

    def expect(*values, &block)
      ensure_not_configured
      unless block_given? ^ !values.empty?
        raise ArgumentError,
              'Need a list of values or a validator block, but not both'
      end
      @expect = block || values
    end

    def converge(description=nil, &block)
      ensure_not_configured
      raise ArgumentError, 'need a block' unless block_given?
      @converge = block
    end

    def tag(*args)
      ensure_not_configured
      raise NotImplementedError
    end

    def run!(ctx = nil)
      return if done?
      @after_converge = false
      unless check!(ctx)
        ctx.instance_exec(&@converge) # TODO: converge as string
        @after_converge = true
        raise "Failed to converge" unless check!(ctx)
      end
      @done = true
    end

    def done?
      @done
    end

    private

    def ensure_not_configured
      raise "Step already configured!" if @configured
    end

    def check!(ctx = nil)
      if @check
        status = if @check.is_a?(Proc)
                   ctx.instance_exec(&@check)
                 else
                   ui.agree(@check)
                 end
        case @expect
        when nil
          status
        when Array
          @expect.include?(status)
        when Proc
          ctx.instance_exec(status, &@expect)
        else
          raise "CAN'T HAPPEN"
        end
      else
        status = @after_converge
      end
    end
  end
end
