if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start
  SimpleCov.add_filter('spec')
end

require 'rspec/expectations'
require 'rspec/mocks'
require 'checklist'

RSpec.configure do |config|
  config.before(:each) do
    Checklist.stub(:say)
  end
end

EXAMPLE_STEPS = [
  [ 'one',   'one done' ],
  [ 'two',   'check two' ],
  [ 'three', 'three it is' ],
  [ 'four',  'here you are', 'A surprise description' ]]

class RSpec::Mocks::Mock
  def stub_checklist_ui
    [
      :say, :header, :start, :finish, :complete, :incomplete, :describe
    ].each { |mm| self.stub(mm) }
    self
  end
end

def example_checklist
  body = RSpec::Mocks::Mock.new('body')
  body.stub(:step)

  cl = Checklist.new('Test',
    :ui => RSpec::Mocks::Mock.new('UI').stub_checklist_ui)

  class << cl ; attr_accessor :body ; end
  cl.body = body

  EXAMPLE_STEPS.each_with_index do |step, ii|
    challenge, response, description = step
    cl.step(challenge, response, description) { body.step(ii) }
  end

  cl
end
