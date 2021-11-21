# frozen_string_literal: true

module SexpCliTools
  module Matchers
    # A matcher that's satisfied by an s-expression containing a method definition.
    class MethodImplementation
      def self.satisfy?(sexp, target_method)
        new(target_method).satisfy?(sexp)
      end

      def initialize(target_method)
        @matcher = Sexp::Matcher.parse("[child (defn #{target_method} ___)]")
      end

      def satisfy?(sexp)
        @matcher.satisfy?(sexp)
      end
    end
  end
end
