require_relative 'sugar'

module Checklist
  class Step
    extend Sugar

    attr_reader :id
    dwim_accessor :challenge
    dwim_accessor :response
    dwim_accessor :description
    dwim_accessor :converge
    dwim_accessor :check

    def initialize(id, &block)
      raise ArgumentError, 'need a block' unless block_given?
      @id = id.to_sym
      @challenge = id.to_s
      instance_exec(self, &block)
      reset!
    end

    def run!
      # TODO: UI
      unless check!
        converge!
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
      @converged = false
    end

    def converge!
      @converged = false
      instance_exec(&@converge)
    ensure
      @converged = true
    end

    def check!
      if @check
        instance_exec(&@check)
      else
        @converged
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
