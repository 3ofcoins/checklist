require 'spec_helper'

describe Checklist do
  let(:checklist) { Checklist.new('Test') }

  it "has a name" do
    checklist.name.should eq 'Test'
  end

  it 'initially has an empty step list' do
    checklist.steps.should eq []
    checklist.length.should eq 0
  end

  it 'initially is not open' do
    checklist.open?.should be false
    checklist.remaining.should be nil
    checklist.completed.should be nil
  end

  it 'initially is not completed' do
    checklist.completed?.should be nil
  end
end

describe Checklist, '#<<' do
  let(:checklist) { Checklist.new('Test') }

  it 'adds new step to a checklist' do
    checklist.steps.should eq []
    step = Checklist.step('foo', 'bar') { nil }
    checklist << step
    checklist.steps.length.should eq 1
    checklist.steps.first.should eq step
  end

  it 'requires argument to be a step' do
    lambda { checklist << 23 }.should raise_error MustBe::Note
  end
end

describe Checklist, '#step' do
  let(:checklist) { Checklist.new('Test') }

  it 'adds new step to a checklist' do
    checklist.steps.should eq []
    checklist.step('foo', 'bar') { 23 }
    checklist.steps.length.should eq 1
    checklist.steps.first.challenge.should eq 'foo'
    checklist.steps.first.response.should eq 'bar'
    checklist.steps.first.description.should be nil
    checklist.steps.first.code.call.should eq 23
  end
end
