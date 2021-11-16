require "thor"
require "sexp_cli_tools"

module SexpCliTools
  class Cli < Thor
    desc "version", "Prints version"
    default_command def version
      puts "SexpCliTools version: %p" % SexpCliTools::VERSION
    end
  end
end
