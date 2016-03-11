require_relative 'sugar'

class Checklist
  class Step
    extend Sugar

    attr_reader :id
    dwim_accessor :challenge
    dwim_accessor :response
    dwim_accessor :description

    def initialize(id, &block)
      raise ArgumentError, 'need a block' unless block_given?
      @id = id.to_sym
      @challenge = id.to_s
      instance_exec(self, &block)
      reset!
    end

    def check(&block)
      @check = block
    end

    def execute(&block)
      @execute = block
    end

    def run!
      # TODO: UI
      unless check!
        execute!
        raise 'Recheck failed!' unless check!
        @done = true
      end
    end

    def done?
      @done
    end

    def to_hash
      { 'Challenge' => challenge,
        'Response' => response,
        'Description' => description }
    end

    private

    def reset!
      @done = false
      @executed = false
    end

    def execute!
      @executed = false
      instance_exec(&@execute)
    ensure
      @executed = true
    end

    def check!
      if @check
        instance_exec(&@check)
      else
        @executed
      end
    end
  end

  # Step = Struct.new(:challenge, :response, :description, :code) do
  #   # Run checklist's body code
  #   def run!
  #     code.call
  #   end

  #   def to_hash
  #     { 'Challenge' => challenge,
  #       'Response' => response,
  #       'Description' => description }
  #   end
  # end
end
