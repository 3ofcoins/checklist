module Checklist
  module TemplateCacheMixin
    def define_template(name, &block)
      raise ArgumentError unless block_given?
      raise ArgumentError, "#{name} already defined" if template_cache.include? name
      template_cache[name] = block
    end

    def render_template(name, opts = {}, *args)
      block = template_cache[name]
      raise ArgumentError, "Undefined template #{name.inspect}" unless block
      new(name, opts) { instance_exec(*args, &block) }
    end

    private

    def template_cache
      @template_cache ||= {}
    end
  end
end
