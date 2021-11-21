# frozen_string_literal: true

require 'thor'
require 'sexp_cli_tools'

module SexpCliTools
  # Top-level command-line interface defining public shell interface.
  class Cli < Thor
    desc 'version', 'Prints version'
    default_command def version
      puts format('SexpCliTools version: %p', SexpCliTools::VERSION)
    end

    option :include, default: '**/*.rb'
    desc "find sexp-matcher [--include='**/*.rb']",
         'Finds Ruby files matching the s-expression matcher in the `include` glob pattern.'
    def find(requested_sexp_matcher, *matcher_params)
      glob = options[:include]
      sexp_matcher = SexpCliTools::MATCHERS[requested_sexp_matcher]
      Pathname.glob(glob).each do |path|
        puts path.to_s if sexp_matcher.satisfy?(RubyParser.new.parse(path.read), *matcher_params)
      end
    end
  end
end
