require_relative './spec_helper'

describe Checklist::Locals do
  subject { Checklist::Locals.new }

  describe '#let' do
    it 'defines lazy helper variables' do
      mark = false
      subject.let(:test) { mark = true }

      expect { subject[:test] }
      expect { mark }             # was set to true by the block
      mark = false
      expect { subject[:test] }
      expect { !mark }            # block did not execute again
    end

    it 'makes locals accessible to other locals' do
      subject.let(:foo) { 2 }
      subject.let(:bar) { foo * 2 }
      expect { subject[:bar] == 4 }
    end

    it 'does not allow redefining an already defined name' do
      subject.let(:foo) { 1 }
      expect { rescuing { subject.let(:foo) { 2 } }.is_a?(ArgumentError) }
    end
  end

  describe '#include?' do
    it 'tells whether a local has been defined' do
      subject.let(:foo) { 2 }
      expect { subject.include?(:foo) }
      expect { !subject.include?(:bar) }
    end

    it 'does not return true for native methods on Module' do
      expect { !subject.include?(:constants) }
    end
  end

  describe '#[]' do
    it 'accesses defined locals' do
      subject.let(:foo) { 2 }
      expect { subject[:foo] == 2 }
    end

    it 'returns nil for undefined locals' do
      expect { subject[:foo].nil? }
    end
  end

  describe 'sandbox (accessor methods)' do
    let(:trace) { [] }
    before do
      the_trace = trace
      subject.let(:foo) do
        the_trace << :foo
        :foo
      end
    end

    describe '#_name_' do
      it 'returns value, but does not rerun generator' do
        expect { trace.empty? }
        expect { subject.sandbox.foo == :foo }
        expect { trace == [:foo] }
        expect { subject.sandbox.foo == :foo }
        expect { trace == [:foo] }
      end
    end

    describe '#_name_!' do
      it 'returns value, but does not rerun generator' do
        expect { trace.empty? }
        expect { subject.sandbox.foo! == :foo }
        expect { trace == [:foo] }
        expect { subject.sandbox.foo! == :foo }
        expect { trace == [:foo, :foo] }
      end

      it 'also reruns when called after regular method' do
        expect { trace.empty? }
        expect { subject.sandbox.foo == :foo }
        expect { trace == [:foo] }
        expect { subject.sandbox.foo! == :foo }
        expect { trace == [:foo, :foo] }
      end
    end
  end

  describe '#new_sandbox' do
    it 'returns an object that includes reader methods' do
      subject.let(:foo) { 2 }
      s1 = subject.new_sandbox
      s2 = subject.new_sandbox
      expect { s1 != s2 }
      expect { s1.foo == 2 }
      expect { s2.foo == 2 }
    end

    it 'returns objects that share result cache' do
      cache = 0
      subject.let(:foo) { cache += 1 }
      s1 = subject.new_sandbox
      s2 = subject.new_sandbox
      expect { s1.foo == 1 }
      expect { s2.foo == 1 }
      expect { cache == 1 }
    end
  end

  describe '#reset!' do
    let(:cache) { subject.send(:memoized_cache) }

    before do
      subject.let(:four)        { 4 }
      subject.let(:eight)       { 8 }
      subject.let(:fifteen)     { 15 }
      subject.let(:sixteen)     { 16 }
      subject.let(:twentythree) { 42 }
      subject.let(:fortytwo)    { 23 }

      expect { cache.empty? }
      subject[:four]
      expect { cache.length == 1 }
      subject[:fifteen]
      expect { cache.length == 2 }
      subject[:twentythree]
      expect { cache.length == 3 }
      subject[:fortytwo]
      expect { cache.length == 4 }
    end

    it 'clears all values from cache when called with no arguments' do
      subject.reset!
      expect { cache.empty? }
    end

    it 'clears only named values when names are provided' do
      subject.reset! :four
      expect { cache.length == 3 }

      subject.reset! :fifteen, :fortytwo
      expect { cache.length == 1 }
    end
  end
end
