require 'spec_helper'

describe Checklist, '#step!' do
  subject { example_checklist() }

  it 'should execute one next step and push it from remaining to completed' do
    Checklist.expect_open
    Checklist.expect_steps(0..3)
    Checklist.expect_nothing_more
    subject.body.expect_steps(0..3)

    subject.open!

    subject.remaining.should == 4
    subject.completed.should == 0

    subject.step!

    subject.remaining.should == 3
    subject.completed.should == 1

    subject.step!
    subject.remaining.should == 2
    subject.completed.should == 2

    subject.step!
    subject.remaining.should == 1
    subject.completed.should == 3

    subject.step!

    subject.remaining.should == 0
    subject.completed.should == 4
  end

  it 'should complete the checklist, eventually' do
    Checklist.expect_open
    Checklist.expect_steps(0..3)
    Checklist.expect_nothing_more
    subject.body.expect_steps(0..3)

    subject.open!

    subject.length.times do
      subject.completed?.should be false
      subject.step!
    end

    subject.completed?.should be true
  end

  it 'should not be allowed when list is completed' do
    Checklist.expect_open
    Checklist.expect_steps(0..3)
    Checklist.expect_nothing_more
    subject.body.expect_steps(0..3)

    subject.open!

    subject.length.times { subject.step! }
    expect { subject.step! }.to raise_exception(RuntimeError)
  end

  it 'should be disallowed when list is not open' do
    # Look, Ma, no open!
    expect { subject.step! }.to raise_exception(RuntimeError)
  end
end
