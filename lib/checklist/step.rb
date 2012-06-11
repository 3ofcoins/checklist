class Checklist
  Step = Struct.new(:challenge, :response, :description, :code) do
    # Run checklist's body code
    def run!
      Checklist.say "** #{self.challenge} ..."
      self.code.call
      Checklist.say "** #{self.challenge} #{self.response}"
    end
  end

  # Create a new Step instance
  def self.step(challenge, response, description=nil, &block)
    raise ArgumentError, 'need a block' unless block_given?
    Step.new(challenge, response, description, block)
  end
end
