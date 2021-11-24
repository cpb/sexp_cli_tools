# frozen_string_literal: true

require 'sexp_processor'

module SexpCliTools
  module Matchers
    # Matches a call to `super` and captures the method name of calling `super`
    class SuperCaller < MethodBasedSexpProcessor
      # Thanks to this test: https://github.com/seattlerb/sexp_processor/blob/93712e31b6d5e23c7d68cea805b40a642aad3e10/test/test_sexp.rb#L1625
      # zsuper I noticed while simplifying the examples
      MATCHER = Sexp::Matcher.parse('[child (super ___)]') | Sexp::Matcher.parse('[child (zsuper)]')

      SexpMatchData = Struct.new(:method_name)

      def self.satisfy?(sexp)
        return if (matches = MATCHER / sexp).empty?

        _sexp, *in_between, _matched_call = matches

        method_definition = Sexp::Matcher.parse('(defn _ ___)')

        method_name = in_between.map do |sub_expr|
          next if (sub_matches = method_definition / sub_expr).empty?

          (_defn, name), *_args_and_implementation = sub_matches

          break name
        end

        SexpMatchData.new(method_name)
      end
    end
  end
end
