require 'spec_helper'

describe Checklist, '#run!' do
  subject { example_checklist() }

  it "should call all the methods" do
    Checklist.expect_open
    Checklist.expect_steps(0..3)
    Checklist.expect_completion
    Checklist.expect_nothing_more
    subject.body.expect_steps(0..3)
 
    def should_receive_and_call(method)
      original_method = subject.method(method)
      subject.should_receive(method) { original_method.call }
    end

    should_receive_and_call(:run!).once
    should_receive_and_call(:open!).once
    should_receive_and_call(:step!).exactly(subject.length).times
    should_receive_and_call(:close!).once

    subject.run!
  end

  it 'should return the checklist itself' do
    subject.body.expect_steps(0..3)
    subject.run!.should == subject
  end

  it 'should raise and report incomplete steps if a step bombs' do
    subject.step('five', 'bomb') do
      raise Exception, 'as planned'
      body.poke5!
    end
    subject.step('six', 'done', 'a description') { body.poke6! }

    Checklist.expect_open
    Checklist.expect_steps(0..3)
    Checklist.expect_say('*** 2 STEPS NOT COMPLETED ***')
    Checklist.expect_say('** five (bomb)')
    Checklist.expect_say(no_args())
    Checklist.expect_say('** six (done)')
    Checklist.expect_say('a description')
    Checklist.expect_say(no_args())
    Checklist.expect_nothing_more
    subject.body.expect_steps(0..3)

    expect { subject.run! }.to raise_exception(Exception)
   end
end
