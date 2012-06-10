require 'must_be'

require "checklist/version"
require 'checklist/step'

class Checklist
  attr_reader :steps, :name

  def initialize(name)
    @steps = []
    @remaining_steps = nil
    @completed_steps = nil
    @name = name
  end

  # appendd a Checklist::Step to the checklist
  def <<(step)
    raise RuntimeError, 'List is open' if open?
    step.must_be_a(Step)
    steps << step
  end

  # create new Checklist::Step and add it to the checklist
  def step(challenge, response, description=nil, &code)
    self << Checklist::step(challenge, response, description, &code)
  end

  # true if checklist is started
  def open?
    !!remaining_steps
  end

  # true if checklist is started and all steps are completed_steps
  def completed?
    remaining_steps && remaining_steps.empty?
  end

  # Number of defined steps
  def length
    steps.length
  end

  # Number of remaining steps or nil if list is not open
  def remaining
    remaining_steps and remaining_steps.length
  end

  # Number of completed steps or nil if list is not open
  def completed
    completed_steps and completed_steps.length
  end

  def open!
    raise RuntimeError, "Checklist is already open" if open?
    puts "*** #{name} ***"
    self.remaining_steps = steps.clone
    self.completed_steps = []
    self
  end

  # Execute one step of the checklist
  def step!
    raise RuntimeError, 'Checklist is completed' if completed?
    remaining_steps.first.run!
    completed_steps << remaining_steps.shift
  end

  # Finish the checklist, print and return outstanding steps
  def close!
    raise RuntimeError, 'Checklist is not open' unless open?
    if completed?
      puts '*** All steps completed ***'
    else
      puts "*** #{remaining_steps.length} STEPS NOT COMPLETED ***"
      remaining_steps.each do |ss|
        puts "** #{ss.challenge} (#{ss.response})"
        puts ss.description if ss.description
        puts
      end
    end
    rv = remaining_steps
    self.remaining_steps = self.completed_steps = nil
    rv
  end

  private
  attr_accessor :remaining_steps, :completed_steps
end
