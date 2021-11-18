module SexpCliTools
  module Matchers
    class MethodImplementation
      def initialize(target_method)
        @matcher = Sexp::Matcher.parse("[child (defn #{target_method} ___)]")
      end

      def satisfy?(sexp)
        @matcher.satisfy?(sexp)
      end
    end
  end
end
