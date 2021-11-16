module SexpCliTools
  module Matchers
    SuperCaller = Sexp::Matcher.parse('[include (call nil super ___)]')
  end
end
