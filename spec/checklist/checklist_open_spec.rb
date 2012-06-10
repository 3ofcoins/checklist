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
  end

  it 'cannot be called twice' do
    checklist.open!
    expect { checklist.open! }.to raise_exception(RuntimeError)
  end
end
