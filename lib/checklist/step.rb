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
    end

    def execute(&block)
      @execute = block
    end

    def run!
      instance_exec(&@execute)
    end

    def to_hash
      { 'Challenge' => challenge,
        'Response' => response,
        'Description' => description }
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
