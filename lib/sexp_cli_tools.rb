require "sexp_cli_tools/version"

require "ruby_parser"

require "sexp_cli_tools/matchers/super_caller"

module SexpCliTools

  MATCHERS = {
    "child-class" => Sexp::Matcher.parse('(class _ (const _) ___)'),
    "parent-class" => Sexp::Matcher.parse('(class _ [not? (const _)] ___)'),
    "super-caller" => Matchers::SuperCaller,
  }.freeze
end
