require 'spec_helper'

describe Checklist, '#close!' do
  subject { example_checklist() }

  it "should report checklist completion" do
    Checklist.expect_open
    Checklist.expect_steps(0..3)
    Checklist.expect_completion
    Checklist.expect_nothing_more
    subject.body.expect_steps(0..3)

    subject.open!
    4.times { subject.step! }
    subject.close!
  end

  it "should report outstanding steps" do
    Checklist.expect_open
    Checklist.expect_steps(0..1)
    Checklist.expect_say('*** 2 STEPS NOT COMPLETED ***')
    (2..3).each do |i|
      Checklist.expect_say("** #{EXAMPLE_STEPS[i][0]} (#{EXAMPLE_STEPS[i][1]})")
      Checklist.expect_say(EXAMPLE_STEPS[i][3]) if EXAMPLE_STEPS[i][3]
      Checklist.expect_say(no_args())
    end
    Checklist.expect_nothing_more
    subject.body.expect_steps(0..1)

    subject.open!
    2.times { subject.step! }
    subject.close!

  end

  it 'should return outstanding steps' do
    subject.body.expect_steps(0)

    subject.open!
    subject.step!
    rv = subject.close!
    rv.should be_instance_of Array
    rv.length.should == 3
    rv.each_with_index do |s, i|
      s.should be_instance_of Checklist::Step
      s.challenge.should == EXAMPLE_STEPS[i+1][0]
      s.response.should == EXAMPLE_STEPS[i+1][1]
    end
  end

  it 'should require checklist to be open' do
    expect { subject.close! }.to raise_exception(RuntimeError)
  end
end
