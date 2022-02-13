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

    option :json, default: false, type: :boolean
    option :include, default: ['**/*.rb'], type: :array
    desc 'find sexp-matcher [--include **/*.rb]',
         'Finds Ruby files matching the s-expression matcher in the `include` glob pattern or file list.'
    def find(requested_sexp_matcher, *matcher_params)
      paths = GlobParser.new(options[:include])
      sexp_matcher = SexpCliTools::MATCHERS[requested_sexp_matcher]

      paths
        .reduce(build_buffer(**kwargs(options))) do |output, sexp|
          matches = sexp_matcher.satisfy?(sexp, *matcher_params)

          output << emit(sexp, matches, **kwargs(options))
        end
        .flush
    end

    # Provides a stream like interface to emitting json
    class JSONBuffer
      def initialize
        @received = []
      end

      def <<(elements)
        @received.push(*elements)
        self
      end

      def flush
        puts JSON.pretty_generate(@received)
      end
    end

    # Provides a stream like interface to emitting filenames
    class PathBuffer
      def initialize
        @received = []
      end

      def <<(elements)
        @received.push(*elements)
        self
      end

      def flush
        puts @received
      end
    end

    no_commands do
      def build_buffer(json:, **_)
        if json
          JSONBuffer.new
        else
          PathBuffer.new
        end
      end

      def sexp(path)
        RubyParser.new.parse(path.read, path)
      end

      def kwargs(indifferent_hash)
        indifferent_hash.transform_keys(&:to_sym)
      end

      def emit(sexp, matches, json:, **_)
        return unless matches

        if json
          matches
        else
          sexp.file
        end
      end
    end
  end
end
