# frozen_string_literal: true

module SexpCliTools
  # Enumerable that reduces globs to yield Sexp
  class GlobParser
    include Enumerable

    # Wrapper for errors encountered parsing globs of supposed files
    class GlobbingError < Error
      attr_reader :error, :path

      def initialize(error, path)
        super(error.message)
        @error = error
        @path = path
      end
    end

    attr_reader :errors

    def initialize(globs, parser: RubyParser.new, errors: [])
      @globs = Array(globs)
      @parser = parser
      @errors = errors
    end

    def each
      @globs.each do |glob|
        Pathname.glob(glob).each do |path|
          yield @parser.process(path.read, path)
        rescue Racc::ParseError => e
          @errors << GlobbingError.new(e, path)
        rescue Errno::EISDIR => e
          @errors << GlobbingError.new(e, path)
        end
      end
    end
  end
end
