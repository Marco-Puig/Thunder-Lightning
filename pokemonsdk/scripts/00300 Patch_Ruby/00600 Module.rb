# Base class of each Class or Module
class Module
  # Delegate a method to a sub object or something else of the instance
  # @example
  #   delegate :height, :@data
  #   is equivalent to
  #   def height; @data.height; end
  # @param method_name [Symbol] method to delegate
  # @param to [Symbol] thing used to delegate (constant symbol, ivar symbol, cvar symbol etc...)
  # @param definition [String, nil] the definition (argument list) to give to the delegation
  # @param return_type [Class, self] YARD specific argument (to help the macro to tell the right return type)
  # @param description [String] YARD specific argument (to help describing the method)
  # @note Source : https://www.rubydoc.info/gems/activesupport/Module:delegate
  # @!macro [attach] delegate
  #   @!method $1($3)
  #     $5
  #     @return [$4] return value of $2.$1($3)
  def delegate(method_name, to = nil, definition = nil, return_type = self, description = nil)
    unless to
      raise ArgumentError, "Delegation needs a target. Supply symbol as second argument (e.g. delegate :hello, :greeter)."
    end
  
    location = caller_locations(1, 1).first
    file, line = location.path, location.lineno

    method_def = [
      "def #{method_name}(#{definition})",
      "_ = #{to}",
      "if !_.nil? || nil.respond_to?(:#{method_name})",
      "  _.#{method_name}(#{definition})",
      "end",
    "end"
    ].join ";"
  
    module_eval(method_def, file, line)
  end
end