require "sexp_cli_tools/version"

require "ruby_parser"

module SexpCliTools

  MATCHERS = {
    "child-class" => Sexp::Matcher.parse('(class _ (const _) ___)'),
    "parent-class" => Sexp::Matcher.parse('(class _ [not? (const _)] ___)'),
  }.freeze
end
