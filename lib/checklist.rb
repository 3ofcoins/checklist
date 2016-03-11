require 'checklist/version'
require 'checklist/step'
require 'checklist/ui'
require 'checklist/wrapper'

class Checklist
  attr_reader :steps, :current, :name, :ui

  def initialize(name, options = {})
    @steps = []
    @remaining_steps = nil
    @completed_steps = nil
    @current = nil
    @name = name
    @ui = options[:ui] || Checklist::UI.new
  end

  # appendd a Checklist::Step to the checklist
  def <<(step)
    raise 'List is open' if open?
    # step.must_be_a(Step)
    steps << step
  end

  # create new Checklist::Step and add it to the checklist
  def step(id, &code)
    self << Step.new(id, &code)
  end

  # true if checklist is started
  def open?
    !!remaining_steps # rubocop:disable Style/DoubleNegation
  end

  # true if checklist is started and all steps are completed_steps
  def completed?
    remaining_steps && remaining_steps.empty?
  end

  # Number of defined steps
  def length
    steps.length
  end

  def empty?
    length == 0 # rubocop:disable Style/ZeroLengthPredicate
  end

  # Number of remaining steps or nil if list is not open
  def remaining
    remaining_steps && remaining_steps.length
  end

  # Number of completed steps or nil if list is not open
  def completed
    completed_steps && completed_steps.length
  end

  def open!
    raise 'Checklist is already open' if open?
    ui.header(self)
    self.remaining_steps = steps.clone
    self.completed_steps = []
    self
  end

  # Execute one step of the checklist
  def step! # rubocop:disable Metrics/AbcSize
    raise 'Checklist is not open' unless open?
    raise 'Checklist is completed' if completed?
    self.current = remaining_steps.first
    ui.start(current)
    current.run!
    ui.finish(current)
    completed_steps << remaining_steps.shift
  end

  # Finish the checklist, print and return outstanding steps
  def close!
    raise 'Checklist is not open' unless open?
    if completed?
      ui.complete(self)
    else
      ui.incomplete(self, remaining_steps)
    end
    rv = remaining_steps
    self.current = nil
    self.remaining_steps = nil
    self.completed_steps = nil
    rv
  end

  # Run the whole thing
  def run!
    open!
    step! until completed?
    self
  ensure
    close!
  end

  private

  attr_writer :current
  attr_accessor :remaining_steps, :completed_steps
end
