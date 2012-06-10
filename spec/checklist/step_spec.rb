require 'spec_helper'

describe Checklist::Step do
  it "is a struct with challenge, response, description, and code fields" do
    step = Checklist::Step.new(
      'the challenge',
      'the response',
      'the description',
      'some code')
    step.challenge.should eq('the challenge')
    step.response.should eq('the response')
    step.description.should eq('the description')
    step.code.should eq('some code')
  end
end

describe Checklist::Step, "#run!" do
  before(:each) do
    @called = false
    @raise = false
    @code = Proc.new do
      if @raise
        raise RuntimeError, "as requested"
      else
        @called = true
      end
    end
    @step = Checklist::Step.new(
      'the challenge',
      'the response',
      'the description',
      @code)
    STDOUT.stub(:puts)
  end

  it "runs the proc from code field" do
    @step.run!
    @called.should be_true
  end

  it "prints challenge at the beginning and challenge&response at the end" do
    STDOUT.should_receive(:puts).with("** the challenge ...").once.ordered
    STDOUT.should_receive(:puts).with("** the challenge the response").once.ordered
    @step.run!
  end

  it "does not catch exceptions raised by code" do
    @raise = true
    STDOUT.should_receive(:puts).with("** the challenge ...").once
    lambda { @step.run! }.should raise_error(RuntimeError, "as requested")
  end
end

describe Checklist, '.step' do
  it "Creates a runnable Checklist::Step instance" do
    called = false
    step = Checklist.step('the challenge', 'the response', 'a description') do
      called = true
    end
    step.challenge.should eq 'the challenge'
    step.response.should eq 'the response'
    step.description.should eq 'a description'

    STDOUT.should_receive(:puts).with("** the challenge ...").once.ordered
    STDOUT.should_receive(:puts).with("** the challenge the response").once.ordered

    step.run!

    called.should be_true
  end

  it "Defaults description to nil" do
    step = Checklist.step('the challenge', 'the response') { nil }
    step.challenge.should eq 'the challenge'
    step.response.should eq 'the response'
    step.description.should be nil    
  end

  it "Requires block" do
    lambda { Checklist.step('foo', 'bar') }.should raise_error(ArgumentError)
  end
end
