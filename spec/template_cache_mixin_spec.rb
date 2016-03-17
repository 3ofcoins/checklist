require_relative './spec_helper'

module Checklist
  class TemplateCacheMixinTest
    extend TemplateCacheMixin

    attr_reader :param, :name, :opts

    def initialize(name, opts, &block)
      @name = name
      @opts = opts
      instance_exec(&block)
    end
  end

  describe TemplateCacheMixin do
    before do
      if TemplateCacheMixinTest.instance_variable_defined?(:@template_cache)
        TemplateCacheMixinTest.remove_instance_variable(:@template_cache)
      end
    end

    it 'is a mixin that keeps a class-wide cache of factories' do
      TemplateCacheMixinTest.define_template('test') { |p| @param = p }

      foo = TemplateCacheMixinTest.render_template('test', {}, :foo)
      bar = TemplateCacheMixinTest.render_template('test', {}, :bar)

      expect { foo.name == 'test' }
      expect { foo.opts == {} }
      expect { foo.param == :foo }
      expect { bar.name == 'test' }
      expect { bar.opts == {} }
      expect { bar.param == :bar }
    end

    it 'does not allow redefining a template' do
      TemplateCacheMixinTest.define_template('test') {}
      exc = rescuing { TemplateCacheMixinTest.define_template('test') {} }
      expect { !exc.nil? }
    end
  end
end
