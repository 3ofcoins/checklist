require 'spec_helper'

describe Checklist, '#step!' do
  let(:body) do
    body = mock('body')
    [ :poke1!, :poke2!, :poke3!, :poke4! ].each do |method|
      body.should_receive(method).once.ordered
    end
    body
  end

  let :checklist do
    checklist = Checklist.new('Test')
    checklist.step('one',   'one done')     { body.poke1! }
    checklist.step('two',   'check two')    { body.poke2! }
    checklist.step('three', 'three it is')  { body.poke3! }
    checklist.step('four',  'here you are') { body.poke4! }
    checklist.open!
    checklist
  end

  before(:each) do
    STDOUT.stub(:puts)
    [ '*** Test ***',
      '** one ...',   '** one one done',
      '** two ...',   '** two check two',
      '** three ...', '** three three it is',
      '** four ...',  '** four here you are' ].each do |msg|
      STDOUT.should_receive(:puts).with(msg)
    end
    STDOUT.should_receive(:puts).exactly(0).times
  end

  it 'should execute one next step and push it from remaining to completed' do
    checklist.remaining.should == 4
    checklist.completed.should == 0

    checklist.step!

    checklist.remaining.should == 3
    checklist.completed.should == 1

    checklist.step!
    checklist.remaining.should == 2
    checklist.completed.should == 2

    checklist.step!
    checklist.remaining.should == 1
    checklist.completed.should == 3

    checklist.step!

    checklist.remaining.should == 0
    checklist.completed.should == 4
  end

  it 'should complete the checklist, eventually' do
    checklist.length.times do
      checklist.completed?.should be false
      checklist.step!
    end
    checklist.completed?.should be true
  end

  it 'should not be allowed when list is completed' do
    checklist.length.times { checklist.step! }
    expect { checklist.step! }.to raise_exception(RuntimeError)
  end
end
