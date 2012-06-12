if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start
  SimpleCov.add_filter('spec')
end

require 'rspec/expectations'
require 'checklist'

RSpec.configure do |config|
  config.before(:each) do
    Checklist.stub(:say)
  end
end

EXAMPLE_STEPS = [
  [ 'one',   'one done',     :poke1! ],
  [ 'two',   'check two',    :poke2! ],
  [ 'three', 'three it is',  :poke3! ],
  [ 'four',  'here you are', :poke4!, 'A surprise description' ]]

def example_checklist(body=nil)
  body = RSpec::Mocks::Mock.new('body') if body.nil?
  if body
    class << body
      def expect_steps(steps)
        steps = [steps] unless steps.respond_to?(:each)
        steps.each do |i|
          self.should_receive(EXAMPLE_STEPS[i][2]).once.ordered
        end
      end
    end
  end

  cl = Checklist.new('Test')

  class << cl
    attr_accessor :body
  end
  cl.body = body

  EXAMPLE_STEPS.each do |challenge, response, method, description|
    cl.step(challenge, response, description) { body and body.send(method) }
  end

  cl
end

class << Checklist
  def expect_say(msg)
    self.should_receive(:say).with(msg)
  end

  def expect_open
    expect_say('*** Test ***')
  end

  def expect_steps(steps, finishes=true)
    steps = [steps] unless steps.respond_to?(:each)
    steps.each do |i|
      expect_say("** #{EXAMPLE_STEPS[i][0]} ...")
      expect_say("** #{EXAMPLE_STEPS[i][0]} #{EXAMPLE_STEPS[i][1]}") if finishes
    end
  end

  def expect_completion
    expect_say('*** All steps completed ***')
  end

  def expect_nothing_more
    self.should_receive(:say).exactly(0).times
  end
end
