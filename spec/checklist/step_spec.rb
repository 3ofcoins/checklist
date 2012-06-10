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
  let(:code_body) do
    code_body = double('code body')
    code_body.should_receive(:poke!)
    code_body
  end
  let(:step) do
    Checklist::Step.new(
      'the challenge',
      'the response',
      'the description',
      lambda { code_body.poke! } )
  end

  before(:each) { STDOUT.stub(:puts) }

  it "runs the proc from code field" do
    step.run!
  end

  it "prints challenge at the beginning and challenge&response at the end" do
    STDOUT.should_receive(:puts).once.with("** the challenge ...").ordered
    STDOUT.should_receive(:puts).once.with("** the challenge the response").ordered
    STDOUT.should_receive(:puts).exactly(0).times
    step.run!
  end

  it "does not catch exceptions raised by code" do
    step.code = lambda { code_body.poke! ; raise RuntimeError }
    STDOUT.should_receive(:puts).with("** the challenge ...").once
    STDOUT.should_receive(:puts).exactly(0).times
    lambda {  step.run! }.should raise_error(RuntimeError)
  end
end

describe Checklist, '::step' do
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
