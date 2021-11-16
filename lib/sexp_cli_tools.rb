# frozen_string_literal: true

require "ruby_parser"

require_relative "sexp_cli_tools/version"
require_relative "sexp_cli_tools/matchers/super_caller"

module SexpCliTools
  class Error < StandardError; end

  MATCHERS = Hash
    .new {|hash, key| hash[key] = Sexp::Matcher.parse(key) }
    .merge({
      "child-class" => Sexp::Matcher.parse('(class _ (const _) ___)'),
      "parent-class" => Sexp::Matcher.parse('(class _ [not? (const _)] ___)'),
      "super-caller" => Matchers::SuperCaller,
    })
end
