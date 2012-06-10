require 'spec_helper'

describe Checklist, '#open!' do
  subject { example_checklist }
  before(:each) { STDOUT.stub(:puts) }

  it 'opens the checklist' do
    STDOUT.expect_open
    subject.open?.should be false
    subject.open!
    subject.open?.should be true
    subject.completed.should == 0
    subject.remaining.should == subject.length
  end

  it 'cannot be called twice' do
    subject.open!
    expect { subject.open! }.to raise_exception(RuntimeError)
  end

  it 'should prevent adding new steps' do
    subject.open!
    expect { subject.step('one', 'one done') { nil } }.
      to raise_exception(RuntimeError)
  end

  it 'returns checklist itself' do
    subject.open!.should == subject
  end
end
