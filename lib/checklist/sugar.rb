class Checklist
  module Sugar
    def dwim_accessor(name)
      ivar = "@#{name}".to_sym
      send(:define_method, name) do |value = nil|
        if value.nil?
          instance_variable_get(ivar)
        else
          instance_variable_set(ivar, value)
        end
      end
    end
  end
end
