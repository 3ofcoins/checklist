class Checklist
  Step = Struct.new(:challenge, :response, :description, :code) do
    # Run checklist's body code
    def run!
      puts "** #{self.challenge} ..."
      self.code.call
      puts "** #{self.challenge} #{self.response}"
    end
  end

  # Create a new Step instance
  def self.step(challenge, response, description=nil, &block)
    raise ArgumentError, 'need a block' unless block_given?
    Step.new(challenge, response, description, block)
  end
end
