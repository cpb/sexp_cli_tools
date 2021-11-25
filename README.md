# SexpCliTools

In this project I am learning and exploring how to create a refactoring tool. The first refactoring tool I wrote in private, and scratched the surface on `SexpProcessor` capabilities. For this refactoring tool, I'm retracing my steps, and taking on a new refactoring goal.

This project focuses on the hook method refactoring described in Chapter 6 of Practical Object-Oriented Design in Ruby by Sandi Metz. In Chapter 6, we are presented with a `Bicycle`, `MountainBike` and `RoadBike` class, with the two specialized bikes calling `super` in a few of their methods. These `super` calls couple `MountainBike` and `RoadBike` to `Bicycle` by requiring them to know the details of the algorithm invoked by `super`. With a hook method refactor, now `Bicycle` can expect that local customizations of `Bicycle` behaviour are fulfilled by subclasses implementing hook methods, which `Bicycle` then calls.

Within the project wiki are my exploratory research notes. I am experimenting with writing as I work. Some of the writing helps me clarify my thinking, some is drafting of content for future posts, and some help me restore state when I change context.

Part of my learning process includes creating a tool that myself and others can use to improve their understanding of, in this case, refactoring tools. While this is a gem, depending on your needs, it might make sense to just go with the *install it yourself* option below.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sexp_cli_tools'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install sexp_cli_tools

## Usage

`sexp find` is the main command-line interface, and it accepts an `Sexp::Matcher.parse` compatible string, and an optional `--include` flag to specify files to limit the search to. By default, `sexp find` will search all `**/*.rb` files.

- `sexp find '[child (class ___)]'` to find class definitions nested in a namespace

In addition to taking any `Sexp::Matcher.parse` pattern, `sexp_cli_tools` contains pre-built matchers for an expanding set of use cases.

- `sexp find method-implementation spares` to find implementations of the method named `spares`

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `bundle exec rake` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

I strive to practice test driven development, and I believe you can observe that from the git history. It certainly provides a convenient experimental loop, and I attribute the emergence of a regression test to that technique.

## Contributing

This is an educational project. My goal is to learn. A favourite way for me to learn is through experimentation. I recognize that reading, research and teaching are also great ways to learn. With my writing, I try and offer a peek into my learning process. With that writing I can share and reflect on what I've tried, what I decided not to try, or what I didn't previously notice.

If you want to contribute, I hope the intention you bring to the contributions are to help me, or others interested in refactoring tools, to learn. I welcome the kind and generous contributions of others, but please consider that my attention might be focused elsewhere, and I might not be able to acknowledge your contribution or interest right away.

Thank you for your interest or curiosity in what or how I do what I do.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
