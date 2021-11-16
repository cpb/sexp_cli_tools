require "thor"
require "sexp_cli_tools"

module SexpCliTools
  class Cli < Thor
    desc "version", "Prints version"
    default_command def version
      puts "SexpCliTools version: %p" % SexpCliTools::VERSION
    end

    desc "find sexp-matcher [**/*.rb]", "Finds Ruby files matching the s-expression matcher in the glob pattern. Defaults to search all Ruby files with the pattern **/*.rb"
    def find(sexp_matcher, glob="**/*.rb")
      Pathname.glob(glob).each do |path|
        next if path.to_s =~ /bicycle/
        puts path.to_s
      end
    end
  end
end
