module StructuredWarnings
  module Kernel
    def warn(*args)
      first = args.shift
      if first.is_a? Class and first < Warning
        warning = first 
        message = args.shift

      elsif first.is_a? Warning
        warning = first.class
        message = first.message

      else
        warning = Warning
        message = first.to_s 
      end

      unless args.empty?
        raise ArgumentError, 
              "wrong number of arguments (#{args.size + 2} for 2)" 
      end

      if warning.active?
        output = Kernel.warner.format(warning, message, caller[1..-1])
        super(output) unless output.nil? or output.to_s.empty? 
      end
    end

    def self.warner
      Dynamic[:warner]
    end

  protected
    def structured_warn(warning, message)
      nil
    end
  end
end
