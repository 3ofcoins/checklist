class Checklist
  # Yields a new checklist to block and runs it
  def self.checklist(*args)
    raise ArgumentError, 'need a block' unless block_given?
    cl = self.new(*args)
    yield cl
    cl.run!
  end
end
