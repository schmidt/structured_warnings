module StructuredWarnings::Kernel
  def warn(*args, **opts)
    Warning.warn(*args, **opts)
  end
end

Object.class_eval { include StructuredWarnings::Kernel }
