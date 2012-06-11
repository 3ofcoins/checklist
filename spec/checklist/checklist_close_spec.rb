require 'spec_helper'

describe Checklist, '#close!' do
  let(:body) { mock('body') }
  subject { example_checklist(body) }

  it "should report checklist completion" do
    Checklist.expect_open
    subject.open!

    Checklist.expect_steps(0..3)
    Checklist.expect_completion
    Checklist.expect_nothing_more
    body.expect_steps(0..3)

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

    subject.open!
    body.expect_steps(0..1)
    2.times { subject.step! }
    subject.close!

  end

  it 'should return outstanding steps' do
    subject.open!
    body.expect_steps(0)
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
