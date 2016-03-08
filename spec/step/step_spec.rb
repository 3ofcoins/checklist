require_relative '../spec_helper'

describe Checklist::Step do
  it 'is a struct with challenge, response, description, and code fields' do
    step = Checklist::Step.new(
      'the challenge',
      'the response',
      'the description',
      'some code')
    expect { step.challenge == 'the challenge' }
    expect { step.response == 'the response' }
    expect { step.description == 'the description' }
    expect { step.code == 'some code' }
  end
end

describe Checklist::Step, '#run!' do
  let(:code_body) do
    code_body = MiniTest::Mock.new
    code_body.expect :poke!, nil
    code_body
  end
  let(:step) do
    Checklist::Step.new(
      'the challenge',
      'the response',
      'the description',
      -> { code_body.poke! })
  end

  it 'runs the proc from code field' do
    step.run!
  end

  it 'does not catch exceptions raised by code' do
    step.code = lambda do
      code_body.poke!
      raise RuntimeError
    end
    expect { rescuing { step.run! }.is_a?(RuntimeError) }
  end
end

describe Checklist, '::step' do
  it 'Creates a runnable Checklist::Step instance' do
    called = false
    step = Checklist.step('the challenge', 'the response', 'a description') do
      called = true
    end

    step.run!
    expect { called == true }
  end

  it 'Defaults description to nil' do
    step = Checklist.step('the challenge', 'the response') { nil }
    expect { step.description.nil? }
  end

  it 'Requires block' do
    expect { rescuing { Checklist.step('foo', 'bar') }.is_a?(ArgumentError) }
  end
end
