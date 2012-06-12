class Checklist
  # Yields a new checklist to block and runs it
  def self.checklist(name)
    raise ArgumentError, 'need a block' unless block_given?
    cl = self.new(name)
    yield cl
    cl.run!
  end
end
