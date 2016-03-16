require_relative './ui'

module Checklist
  def self.Step(name, &block)
    Step.define_template(name, &block)
  end

  class Step
    class << self
      def define_template(name, &block)
        raise ArgumentError unless block_given?
        (@cache ||= {})[name] = block
      end

      def render_template(name, opts = {}, *args)
        block = (@cache ||= {})[name]
        raise ArgumentError, "Undefined template #{name.inspect}" unless block
        new(name, opts) { instance_exec(*args, &block) }
      end
    end

    attr_reader :name, :ui, :opts, :status

    def initialize(name, opts = {}, &block)
      @name = name
      @ui = opts.fetch(:ui) { UI.new(opts) }
      @opts = opts
      @check = nil
      @expect = nil
      @converge = nil
      @configured = false

      instance_exec(self, &block) if block_given?
      raise 'No converge provided' unless @converge
      @configured = true

      reset!
    end

    def reset!
      @status = nil
      @value = nil
      @after_converge = nil
    end

    def check(question = nil, &block)
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

    def converge(&block)
      ensure_not_configured
      raise ArgumentError, 'need a block' unless block_given?
      @converge = block
    end

    def run!(ctx = nil)
      report
      return unless status.nil?
      @status = :started
      until check!(ctx)
        raise 'Cannot converge' unless recheck?
        converge!(ctx)
      end
      @status = :done
    rescue => e
      @status = :error
      @value = e
      raise
    ensure
      report
    end

    def done?
      status == :done
    end

    def report
      ui.say opts[:number] && Rainbow("##{opts[:number]}.").white.bright,
             Rainbow(name).underline,
             status_for_report
    end

    private

    STATUS_COLORS = {
      started: :yellow,
      pass: :green,
      done: :green,
      fail: :red,
      error: :red }.freeze

    STATUS_MARKS = {
      nil => ' ',
      started: UI::UnicodeDWIM['…', '...'],
      done: UI::UnicodeDWIM['✓', 'OK'],
      pass: UI::UnicodeDWIM['✓', 'OK'],
      fail: UI::UnicodeDWIM['✗', 'FAIL'],
      error: UI::UnicodeDWIM['🔥', 'ERROR'] }.freeze

    def status_s
      STATUS_MARKS.fetch(status) { status }.to_s.upcase
    end

    def status_for_report
      col = STATUS_COLORS.fetch(@status, :white)
      pieces = [
        Rainbow('[').color(col),
        Rainbow(status_s).color(col).bright]
      unless [nil, true, false].include?(@value)
        pieces << Rainbow(':').color(col)
        pieces << Rainbow(@value.to_s).color(col).underline
      end
      pieces << Rainbow(']').color(col)
      pieces.join
    end

    def report_action(message)
      ui.say Rainbow(UI::UnicodeDWIM['➤', '>>']).white.bright,
             message,
             UI::UnicodeDWIM['…', '...']
    end

    def ensure_not_configured
      raise 'Step already configured!' if @configured
    end

    def recheck?
      opts[:keep_on_trying] || !@after_converge
    end

    def check!(ctx = nil)
      check_execute(ctx)
      check_interpret(ctx).tap do |passed|
        @status = passed ? :pass : :fail
        report if @check.is_a?(Proc)
      end
    end

    def check_execute(ctx)
      @value =
        case @check
        when nil
          @after_converge
        when Proc
          report_action 'Checking'
          ctx.instance_exec(&@check)
        else
          ui.agree(@check)
        end
    end

    def check_interpret(ctx)
      case @expect
      when nil
        !!@value # rubocop:disable Style/DoubleNegation
      when Array
        @expect.include?(@value)
      when Proc
        ctx.instance_exec(@value, &@expect)
      else
        # :nocov:
        raise "CAN'T HAPPEN"
        # :nocov:
      end
    end

    def converge!(ctx)
      report_action 'Converging'
      ctx.instance_exec(&@converge) # TODO: converge as string
      @after_converge = true
    end
  end
end
