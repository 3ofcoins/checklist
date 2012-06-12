require 'spec_helper'

describe Checklist, '#close!' do
  subject { example_checklist }

  it "should report checklist completion" do
    subject.ui.should_receive(:complete).with(subject)

    subject.open!
    subject.length.times { subject.step! }
    subject.close!
  end

  it "should report outstanding steps" do
    subject.ui.should_receive(:incomplete).with(subject, subject.steps[2..3])

    subject.open!
    2.times { subject.step! }
    subject.close!
  end

  it 'should return outstanding steps' do
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
