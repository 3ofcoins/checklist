module Checklist
  class Locals
    attr_reader :namespace
    def initialize
      @namespace = Module.new
    end

    def let(name, &block)
      raise ArgumentError, 'Need a block' unless block_given?
      raise ArgumentError, "Invalid name #{name}" unless name.to_s =~ /^[a-zA-Z_][a-zA-Z0-9]*$/ # rubocop:disable Metrics/LineLength
      raise ArgumentError, "#{name} already defined" if include?(name)

      memoized = memoized_cache
      name = name.to_sym

      namespace.__send__ :define_method, name do
        memoized.fetch(name) { |k| memoized[k] = instance_eval(&block) }
      end

      namespace.__send__ :define_method, "#{name}!" do
        memoized[name] = instance_eval(&block)
      end
    end

    def include?(name)
      name = canonicalize_name(name)
      namespace.instance_methods.include?(name)
    end

    def [](name)
      name = canonicalize_name(name)
      sandbox.__send__(name) if include?(name)
    end

    def reset!(*names)
      if names.empty?
        memoized_cache.clear
      else
        names.each { |name| memoized_cache.delete(canonicalize_name(name)) }
      end
    end

    def infest(obj)
      (class << obj; self; end).include(namespace)
      obj
    end

    def new_sandbox
      infest(BasicObject.new)
    end

    def sandbox
      @sandbox ||= new_sandbox
    end

    private

    def memoized_cache
      @memoized_cache ||= {}
    end

    def canonicalize_name(name)
      name.to_s.sub(/!*$/, '').to_sym
    end
  end
end
