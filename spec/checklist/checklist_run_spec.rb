require 'spec_helper'

describe Checklist, '#run!' do
  let(:body) { mock('body') }
  subject { example_checklist(body) }
  before(:each) { STDOUT.stub(:puts) }

  it "should call all the methods" do
    subject

    STDOUT.expect_open
    STDOUT.expect_steps(0..3)
    STDOUT.expect_completion
    STDOUT.expect_nothing_more
    body.expect_steps(0..3)
 
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

  it 'should raise and report incomplete steps if a step bombs' do
    subject.step('five', 'bomb') do
      raise Exception, 'as planned'
      body.poke5!
    end
    subject.step('six', 'done', 'a description') { body.poke6! }

    STDOUT.expect_open
    STDOUT.expect_steps(0..3)
    STDOUT.expect_puts('*** 2 STEPS NOT COMPLETED ***')
    STDOUT.expect_puts('** five (bomb)')
    STDOUT.expect_puts(no_args())
    STDOUT.expect_puts('** six (done)')
    STDOUT.expect_puts('a description')
    STDOUT.expect_puts(no_args())
    STDOUT.expect_nothing_more
    body.expect_steps(0..3)

    expect { subject.run! }.to raise_exception(Exception)
   end
end
