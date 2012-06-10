require 'spec_helper'

describe Checklist, '#step!' do
  let(:body) { mock('body') }
  subject { example_checklist(body).open! }

  before(:each) do
    STDOUT.stub(:puts)
    STDOUT.expect_open
    STDOUT.expect_steps(0..3)
    STDOUT.expect_nothing_more
    subject                     # to initialize lazy vars
    body.expect_steps(0..3)
  end

  it 'should execute one next step and push it from remaining to completed' do
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
    subject.length.times do
      subject.completed?.should be false
      subject.step!
    end
    subject.completed?.should be true
  end

  it 'should not be allowed when list is completed' do
    subject.length.times { subject.step! }
    expect { subject.step! }.to raise_exception(RuntimeError)
  end
end
