class Checklist
  module Sugar
    def dwim_accessor(name, &block)
      send(:define_method, name, dwim_accessor_proc(name, &block))
    end

    private

    # rubocop:disable Metrics/PerceivedComplexity
    def dwim_accessor_proc(name, &postprocess_block)
      ivar = "@#{name}".to_sym
      proc do |value = nil, &block|
        if block
          unless value.nil?
            raise ArgumentError,
                  'Please provide either block or value, not both'
          end
          value = block
        end

        if value.nil?
          val = instance_variable_get(ivar)
          if val.is_a?(Proc)
            instance_exec(val)
          else
            val
          end
        else
          # rubocop:disable Performance/RedundantBlockCall
          value = postprocess_block.call(value) if postprocess_block
          instance_variable_set(ivar, value)
        end
      end
    end
  end
end
