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
        processor = new
        processor.process(sexp)

        processor.matches if processor.matched?
      end

      attr_reader :matches

      def initialize(*)
        super

        @matches = []
      end

      def process_defn(exp)
        super do
          @matches << SexpMatchData.new(method_name.gsub(/^#/, '').to_sym) if exp.satisfy?(MATCHER)
        end
      end

      def matched?
        !@matches.empty?
      end
    end
  end
end
