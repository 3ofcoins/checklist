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
    it 'runs the execute block' do
      world = Hash.new { |h, k| h[k] = 0 }
      step = Checklist::Step.new :foo do
        execute { world[:foo] += 1 }
      end
      step.run!
      expect { world == { foo: 1 } }
    end

    it 'does not catch exceptions raised by code' do
      step = Checklist::Step.new :foo do
        execute { raise 'Boo!' }
      end
      expect { rescuing { step.run! }.is_a?(RuntimeError) }
    end

    it 'runs the check block and skips execute if true' do
      world = Hash.new { |h, k| h[k] = 0 }
      step = Checklist::Step.new :foo do
        check { world[:check] += 1 }
        execute { world[:exec] += 1 }
      end
      step.run!
      expect { world == { check: 1 } }
    end

    it 'reruns the check block after execute' do
      world = Hash.new { |h, k| h[k] = 0 }
      step = Checklist::Step.new :foo do
        check do
          world[:check] += 1
          world[:exec] > 0
        end
        execute { world[:exec] += 1 }
      end
      step.run!
      expect { world == { check: 2, exec: 1 } }
    end
  end
end
