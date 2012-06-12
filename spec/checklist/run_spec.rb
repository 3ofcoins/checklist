require 'spec_helper'

describe Checklist, '#run!' do
  subject { example_checklist }

  it "should call all the methods and execute all the steps" do
    def should_receive_and_call(method)
      original_method = subject.method(method)
      subject.should_receive(method) { original_method.call }
    end

    should_receive_and_call(:run!).once
    should_receive_and_call(:open!).once
    should_receive_and_call(:step!).exactly(subject.length).times
    should_receive_and_call(:close!).once

    subject.body.should_receive(:step).with(0).once
    subject.body.should_receive(:step).with(1).once
    subject.body.should_receive(:step).with(2).once
    subject.body.should_receive(:step).with(3).once

    subject.run!
  end

  it 'should return the checklist itself' do
    subject.run!.should == subject
  end

  it 'should raise and report incomplete steps if a step bombs' do
    subject.step('five', 'bomb') do
      raise Exception, 'as planned'
      body.step(5)
    end
    subject.step('six', 'done', 'a description') { body.step(6) }

    subject.body.should_not_receive(:step).with(5)
    subject.body.should_not_receive(:step).with(6)

    subject.ui.should_receive(:incomplete).with(subject).once
    subject.ui.should_receive(:describe).with(subject.steps[4]).once
    subject.ui.should_receive(:describe).with(subject.steps[5]).once

    expect { subject.run! }.to raise_exception(Exception)
   end
end
