require 'spec_helper'

describe Checklist, '#step!' do
  subject { example_checklist() }

  it 'should execute one next step and push it from remaining to completed' do
    subject.open!

    subject.remaining.should == 4
    subject.completed.should == 0

    subject.body.should_receive(:step).with(0).once
    subject.step!

    subject.remaining.should == 3
    subject.completed.should == 1

    subject.body.should_receive(:step).with(1).once
    subject.step!

    subject.remaining.should == 2
    subject.completed.should == 2

    subject.body.should_receive(:step).with(2).once
    subject.step!

    subject.remaining.should == 1
    subject.completed.should == 3

    subject.body.should_receive(:step).with(3).once
    subject.step!

    subject.remaining.should == 0
    subject.completed.should == 4
  end

  it 'should complete the checklist, eventually' do
    subject.open!

    subject.length.times do
      subject.completed?.should be false
      subject.step!
    end

    subject.completed?.should be true
  end

  it 'should not be allowed when list is completed' do
    subject.open!

    subject.length.times { subject.step! }
    expect { subject.step! }.to raise_exception(RuntimeError)
  end

  it 'should report task start and finish' do
    
  end

  it 'should be disallowed when list is not open' do
    # Look, Ma, no open!
    expect { subject.step! }.to raise_exception(RuntimeError)
  end
end
