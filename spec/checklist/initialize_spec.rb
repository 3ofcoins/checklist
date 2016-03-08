require_relative '../spec_helper'

describe Checklist do
  let(:checklist) { Checklist.new('Test') }

  it 'has a name' do
    expect { checklist.name == 'Test' }
  end

  it 'initially has an empty step list' do
    expect { checklist.steps.empty? }
    expect { checklist.empty? }
  end

  it 'initially is not open' do
    expect { !checklist.open? }
    expect { checklist.remaining.nil? }
    expect { checklist.completed.nil? }
  end

  it 'initially is not completed' do
    expect { checklist.completed?.nil? }
  end
end

describe Checklist, '#<<' do
  let(:checklist) { Checklist.new('Test') }

  it 'adds new step to a checklist' do
    expect { checklist.steps.empty? }
    step = Checklist.step('foo', 'bar') { nil }
    checklist << step
    expect { checklist.steps.length == 1 }
    expect { checklist.steps.first == step }
  end

  it 'requires argument to be a step' do
    raise MiniTest::Skip
    expect { rescuing { checklist << 23 }.is_a? MustBe::Note } # rubocop:disable Lint/UnreachableCode,Metrics/LineLength
  end
end

describe Checklist, '#step' do
  let(:checklist) { Checklist.new('Test') }

  it 'adds new step to a checklist' do
    expect { checklist.steps.empty? }
    checklist.step('foo', 'bar') { 23 }
    expect { checklist.steps.length == 1 }
    expect { checklist.steps.first.challenge == 'foo' }
    expect { checklist.steps.first.response == 'bar' }
    expect { checklist.steps.first.description.nil? }
    expect { checklist.steps.first.code.call == 23 }

    checklist.step('one',   'one done')     { nil }
    checklist.step('two',   'check two')    { nil }
    checklist.step('three', 'three it is')  { nil }
    expect { checklist.length == 4 }
  end
end
