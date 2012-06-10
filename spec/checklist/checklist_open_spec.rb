require 'spec_helper'

describe Checklist, '#open!' do
  let(:checklist) { Checklist.new('Test') }
  before(:each) { STDOUT.stub(:puts) }

  it 'opens the checklist' do
    STDOUT.should_receive(:puts).with(
      '*** Test ***')
    checklist.open?.should be false
    checklist.open!
    checklist.open?.should be true
    checklist.completed.should == 0
    checklist.remaining.should == checklist.length
  end

  it 'sets all steps in remaining' do
    checklist.step('one',   'one done')     { nil }
    checklist.step('two',   'check two')    { nil }
    checklist.step('three', 'three it is')  { nil }
    checklist.open!
    checklist.length.should == 3
    checklist.remaining.should == 3
    checklist.completed.should == 0
  end

  it 'cannot be called twice' do
    checklist.open!
    expect { checklist.open! }.to raise_exception(RuntimeError)
  end

  it 'should prevent adding new steps' do
    checklist.open!
    expect { checklist.step('one', 'one done') { nil } }.
      to raise_exception(RuntimeError)
  end
end
