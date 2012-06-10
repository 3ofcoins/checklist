require 'must_be'

require "checklist/version"
require 'checklist/step'

class Checklist
  attr_reader :steps, :name

  def initialize(name)
    @steps = []
    @remaining = nil
    @completed = nil
    @name = name
  end

  # appendd a Checklist::Step to the checklist
  def <<(step)
    step.must_be_a(Step)
    steps << step
  end

  # create new Checklist::Step and add it to the checklist
  def step(challenge, response, description=nil, &code)
    self << Checklist::step(challenge, response, description, &code)
  end

  # true if checklist is started
  def open?
    !!remaining
  end

  # true if checklist is started and all steps are completed
  def completed?
    remaining && remaining.empty?
  end

  def open!
    raise RuntimeError, "Checklist is already open" if open?
    puts "*** #{name} ***"
    self.remaining = steps.clone
    self.completed = []
  end

  private
  attr_accessor :remaining, :completed
end
