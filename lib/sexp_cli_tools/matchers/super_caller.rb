# frozen_string_literal: true

module SexpCliTools
  module Matchers
    # Thanks to this test: https://github.com/seattlerb/sexp_processor/blob/93712e31b6d5e23c7d68cea805b40a642aad3e10/test/test_sexp.rb#L1625
    # zsuper I noticed while simplifying the examples
    SuperCaller = Sexp::Matcher.parse('[child (super ___)]') | Sexp::Matcher.parse('[child (zsuper)]')
  end
end
