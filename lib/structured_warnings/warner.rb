module StructuredWarnings
  class Warner
    def format(warning, message, stack)
      "#{stack.shift} : #{message} (#{warning})"
    end

#    formats an exception like stack frame
#    def collect_frame(stack)
#      stack.collect { |frame| "        from #{frame}" }.join("\n")
#    end
  end
end
