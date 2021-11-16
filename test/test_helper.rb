# frozen_string_literal: true
#
$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "sexp_cli_tools"

require "minitest/autorun"

require "pry"

def fixture_code(basename, relative_path=Pathname.new('test/fixtures/coupling_between_superclasses_and_subclasses'))
  relative_path.join(basename).read
end

def parse_file(basename)
  RubyParser.new.parse(fixture_code(basename))
end
