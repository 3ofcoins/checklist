require_relative '../spec_helper'

describe Checklist::Step do
  it 'is a struct with challenge, response, description, and code fields' do
    step = Checklist::Step.new :an_id do
      challenge 'the challenge'
      response 'the response'
      description 'the description'
    end

    expect { step.id == :an_id }
    expect { step.challenge == 'the challenge' }
    expect { step.response == 'the response' }
    expect { step.description == 'the description' }
  end

  describe '#initialize' do
    it 'Creates a runnable Checklist::Step instance' do
      called = false
      step = Checklist::Step.new :name do
        execute do
          called = true
        end
      end

      step.run!
      expect { called == true }
    end

    it 'Defaults description to nil' do
      step = Checklist::Step.new(:foo) { nil }
      expect { step.description.nil? }
    end

    it 'Requires block' do
      expect { rescuing { Checklist::Step.new(:foo) }.is_a?(ArgumentError) }
    end
  end

  describe '#run!' do
    let(:code_body) do
      code_body = MiniTest::Mock.new
      code_body.expect :poke!, nil
      code_body
    end

    let(:step) do
      body_var = code_body
      Checklist::Step.new :foo do
        challenge 'the challenge'
        response 'the response'
        description 'the description'
        execute { body_var.poke! }
      end
    end

    it 'runs the proc from code field' do
      step.run!
    end

    it 'does not catch exceptions raised by code' do
      body_var = code_body
      step.execute do
        body_var.poke!
        raise RuntimeError
      end
      expect { rescuing { step.run! }.is_a?(RuntimeError) }
    end
  end
end
