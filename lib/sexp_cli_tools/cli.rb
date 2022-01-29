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

    option :only_inferences, default: false, type: :boolean
    option :include, default: ['**/*.rb'], type: :array
    desc 'find sexp-matcher [--include **/*.rb]',
         'Finds Ruby files matching the s-expression matcher in the `include` glob pattern or file list.'
    def find(requested_sexp_matcher, *matcher_params)
      globs = options[:include]
      sexp_matcher = SexpCliTools::MATCHERS[requested_sexp_matcher]
      globs.each do |glob|
        Pathname.glob(glob).each do |path|
          matches = sexp_matcher.satisfy?(RubyParser.new.parse(path.read), *matcher_params)

          emit(path, matches, **kwargs(options))
        end
      end
    end

    no_commands do
      def kwargs(indifferent_hash)
        indifferent_hash.transform_keys(&:to_sym)
      end

      def emit(path, matches, only_inferences:, **_)
        return unless matches

        if only_inferences
          puts matches.map(&:inference)
        else
          puts path.to_s
        end
      end
    end
  end
end
