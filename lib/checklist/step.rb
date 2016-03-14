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

    def check(&block)
      ensure_not_configured
      raise ArgumentError, 'need a block' unless block_given?
      @check = block
    end

    def expect(*values, &block)
      ensure_not_configured
      if !(block_given? ^ !values.empty?)
        raise ArgumentError,
              'Need a list of values or a validator block, but not both'
      elsif block_given?
        @expect = block
      else
        @expect = values
      end
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
        converge!(ctx)
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
        status = ctx.instance_exec(&@check)
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

    def converge!(ctx = nil)
      if @converge
        ctx.instance_exec(&@converge) # TODO: converge as string
      else
        raise "FAIL" unless ui.yes_or_no("#{name}?")
      end
    end
  end
end
