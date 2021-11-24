# sexp_cli_tools
Educational project exploring the utility in searching and manipulating codebases using S-expressions.

## Inspiration

I once found wide spread use of a "magical" Ruby method which was unnecessary. The intent of this method was to relieve the developer from the repetition of setting instance variables from method parameters. How this magic method did this was difficult to understand for most. Upon examining this method, I noticed it made costly calls to do at run time what could have been done by a developer with a keyboard, or if you wanted to, with code at load time.

I was new to the team and project, and because the use of this method was wide spread, I wanted a systematic and repeatable approach to refactoring it out of existence so that I and my new colleagues could trust the widespread change.

## Concrete Examples We Can All Learn From

### Decoupling Subclasses Using Hook Messages

In Chapter 6 of Practical Object-Oriented Design in Ruby by Sandi Metz, part of the discussion is focused on finding the ideal coupling between child and parent classes. One proposal introduced in that chapter is to use hook methods, instead of calling super.

Lets imagine a scenario where we have achieved total consensus in an organization, and the new direction is to dogmatically use hook methods, instead of calling super.

#### Goal

- Replace methods that call super with a hook method
- Modify parent class' implementation of the supered method to call hook methods

#### Initial state

We will begin with the classes [`Bicycle`](test/fixtures/coupling_between_superclasses_and_subclasses/bicycle.rb), [`RoadBike`](test/fixtures/coupling_between_superclasses_and_subclasses/road_bike.rb) and [`MountainBike`](test/fixtures/coupling_between_superclasses_and_subclasses/mountain_bike.rb). We will build them up to  the state from **Managing Coupling Between Superclasses and Subclasses** until we can recognize the important parts of the "discernible pattern."

#### Milestones

Things we must be able to interogate about this code:
- Which are the children, and which is the parent class?
- Which methods call super, and which is the method that responds to super?
- What in each method that calls super needs to be in the respective hook method?
- What change needs to occur in the method responding to super to leverage the hook methods?

#### Finding the parent of child classes

An s-expression for an empty class in Ruby, as parsed by `ruby_parser`, looks like this:

``` ruby
class Bicycle

end
```

```ruby
s(:class, :Bicycle, nil)
```

An s-expression has a **type** and a **body**. The above s-expression's **type** is `:class` and the body is `s(:Bicycle, nil)`.

An s-expression for an empty class with a parent looks like this:

``` ruby
class MountainBike < Bicycle

end
```

```ruby
s(:class, :MountainBike, s(:const, Bicycle))
```

This s-expression's **type** is still `:class`, but the `body` is: `s(:MountainBike, s(:const, :Bicycle))`.

An s-expression is a representation of the abstract syntax tree, and the s-expressions generated by `ruby_parser` use this `sexp_body` recursion to create that tree.

##### Matching a class

`ruby_parser` comes with a class `Sexp::Matcher` which provides a terse syntax that we can use to select nodes from the s-expression tree.

The `Sexp::Matcher` expression that matches any class definition is: `(class ___)`. That expression uses the triple underscore `___` wildcard to match anything following a `class` **type** s-expression.

##### Matching a class with an explicit parent

The `Sexp::Matcher` expression that matches any class with an explicit parent is: `(class _ (const _) ___)`. This uses the single underscore `_` positional wild card match, and then matches the constant s-expression containing the parent class.

##### Matching a class with an implicit parent

It is also possible to include negation in `Sexp::Matcher`. A class with an implicit parent does not have the constant s-expression `(const _)`. Right now, our class s-expression matcher, `(class ___)` matches all our classes. To match only `Bicycle` we must use negation. That s-expression is `(class _ [not? (const _)] ___)`.

##### Capturing what we've learned in a tool that people can use

Knowing the syntax for `Sexp::Matcher` expressions gives us some confidence that we can start iterating on a tool to help us achieve our goal. The implicit expectation in the project name is that a command line interface is provided. To complete an initial release of a command line tool, we'll use the rubygem `aruba` to help with test setup and teardown.

The `sexp` command offers a convenient shortcut to the `Sexp::Matcher` expressions we'll develop. As we figure out the s-expression matchers along the way, we can add to the list of known matchers to create simple shortcuts, like with the builtin `sexp find child-class` or `sexp find parent-class`.

- Checkout the [tests for examples](https://github.com/cpb/sexp_cli_tools/blob/main/test/sexp_cli_tools/cli_test.rb#L34-L54) of how to test drive your own.
- Checkout the [implementation](https://github.com/cpb/sexp_cli_tools/blob/main/lib/sexp_cli_tools.rb#L8-L9) to see how easy it is to add one.

#### Methods that call super, and methods that are super

##### Iterating on figuring out `Sexp::Matcher` patterns

What isn't shown in [the commit which added the `Sexp::Matcher`](https://github.com/cpb/sexp_cli_tools/commit/34db6012b03f705b1d9c23025d3636fbf9d801dd) is the trial and error in the console trying to remember the terse rules.

Setting up a unit test can help close that iteration loop. [Consider the unit test for `SexpCliTools::Matchers::SuperCaller`](test/sexp_cli_tools/matchers/super_caller_test.rb)

Allowing users to experiment with s-expressions might enable exploration and discovery. The `sexp find` command also supports inline s-expressions. Try these in your projects:

- `sexp find '(class ___)'` to find class definitions
- `sexp find '[child (class ___)]'` to find class definitions nested in a namespace
- `sexp find '[child (case ___)]'` to find case statements

So having test driven the development of [the `super-caller` matcher](lib/sexp_cli_tools/matchers/super_caller.rb) next we have to find the methods that respond to `super`.

##### Finding super implementations

So far we've been using `Sexp::Matcher` strings to find quite abstract parts of our code. But, it's completely possible to fill in what in the parts we know that we'd like to find.

- `sexp find '(class :Bicycle ___)'` from my working copy of this project turns up the [test fixture file for `Bicycle`](https://github.com/cpb/sexp_cli_tools/blob/eb6ebe8722cd13cc91ba12bc69380e09c3bdfe0d/test/fixtures/coupling_between_superclasses_and_subclasses/bicycle.rb), as well as the copy of it `aruba` makes in the `tmp/` directory for testing purposes.
- `sexp find '[child (defn :initialize ___)]'` only turns up the [test fixture file for `RoadBike`](https://github.com/cpb/sexp_cli_tools/blob/eb6ebe8722cd13cc91ba12bc69380e09c3bdfe0d/test/fixtures/coupling_between_superclasses_and_subclasses/test/fixtures/coupling_between_superclasses_and_subclasses/road_bike.rb). I guess it is time to fill in more of our `Bicycle` class!

Finding the super implementation will involve finding a class that contains a method defintion. So far, our matchers haven't taken any parameters. A (naive) matcher for a super implementation might have two parameters, the name of the class we expect to define the method, and the name of the method.

##### Passing matcher parameters

Early on I chose to have the second sequence argument to the command line interface `sexp find` the glob pattern of files to include in the search. However, I want to prioritize matcher parameters for that position now. Although my test coverage didn't include tests for that glob pattern, I did document it.

So, when I [moved that out into the `--include` command line option](https://github.com/cpb/sexp_cli_tools/pull/12/commits/af66f0b7da549426ee0b6444f46b317da279e9a0), that was a breaking change to the public interface. That would necessitate incrementing the major version number according to semantic versioning. I have a hunch that because I'm still in the `0` major release, I could get away with not bumping it. But, I think the `--include` is something I can stick to.

What I remember about semantic versioning is that additions can just be minor version bumps. So, as long as I don't make a backwards incompatible change to the `find` command or the `--include` option I should be good.

Following merge of: [✨ `sexp find method-implementation passed_method` lists files that define the passed method](https://github.com/cpb/sexp_cli_tools/pull/12) I'll release `v1.0.0`! In that PR I chose to do inside-out testing because the `aruba` tests are a bit slow.

I found it helpful to run just the CLI command tests I was working on using the `TEST` and `TESTOPTS` options to the `rake` test tast, like so:

```shell
rake TEST='test/sexp_cli_tools/cli_test.rb' TESTOPTS="--name=/method-implementation/"
```

##### Capturing data from Matches

I believe it is useful to think of `Sexp::Matcher` patterns as analogous to `Regexp` patterns.

One of the differences is that a `Regexp` matches a pattern in a `String`, [whereas `Sexp::Matcher` matches an s-expressions "as a whole or in a sub-tree"](#todo-link-to-Sexp::Matcher#=~).

Revisiting our example of the empy `Bicycle` class:

``` ruby
class Bicycle

end
```

```ruby
s(:class, :Bicycle, nil)
```

We can consider that a `Regexp` `/class \w+/` matches part of the `String` of the contents of the file, and the `Sexp::Matcher` `(class _ ___)` similarly matches a sub-tree of the s-expression.

With `Sexp::Matcher` we could match the whole s-expression tree with: `(class _ nil)`.

A feature of `Regexp` that I think would get us closer to our goals is something analogous to `MatchData`. `MatchData` returned from a `Regexp` match captures the fragment in the `String` the `Regexp` matched.

Our primative `class` statement `Regexp`'s `MatchData` would include `"class Bicycle"`. This is roughly similar to using `Sexp::Matcher#/` or `Sexp::Matcher#search_each` which return or yeild the matching sub-trees.

Returned `MatchData` also includes any **capture groups** the `Regexp` matched. If we change our primative `Regexp` to use a **named capture group** we'd get a `Hash` like mapping for our named captured groups to the fragments they captured. So, `/class (?<class_name>\w+)/` would return a `MatchData` with `match_data[:class_name] == 'Bicycle'`

We need to be able to capture the name of the method that calls super, in order to find the correct method implementation in the superclass to modify with a hook method call. We also need to find the name of the superclass for the subclass with a method that calls super.

We'll next create an API inspired by `MatchData` and named capture groups. Then, we'll modify our `super-caller` matcher to capture the name of the method and the name of the superclass.

###### Capturing the method name of a super caller

Given we used test driven development to create our `SuperCaller` we now have a good basis from which we can explore the impacts of enhancing `#satisfy?` to return so-called match data.

####### Experimentation notes

- [x] Will our `wont_be :satisfy?` or `must_be :satisfy?` expectations break if we return something different?
  - Right now `SexpCliTools::Matchers::SuperCaller` isn't a class we've defined, but a simple instance of `Sexp::Matcher`
    1. Refactor to create a class that passes the current tests.
      - Change the definition to be a class with the same name
      - Capture the `Sexp::Matcher` instance in a class constant
      - Define a class method `satisfy?` that calls `satisfy?` on the class constant `Sexp::Matcher`
    2. Change the `#satisfy?` return value
      - [x] What is the returned by `Sexp::Matcher#satisfy?` ?
        - Calling `#tap` on the last call in a method and calling `binding.pry` is a handy way to check out what a method will return.
        - I saw `true` or `false`
      - [x] If we return an instance of a `Struct` with fields for the data we want to capture, will it still pass?
        - **Yes** an instance of most objects is *truthy*.
        - Define a `Struct` internal to our `SuperCaller` matcher
        - If our `Sexp::Matcher` is satisfied by the passed in s-expression, return a new instance of that `Struct`
      - [x] Can we always return an object, or if there is no match, do we need to return something that is already falsey? Can we make an object which is falsey?
        - Not sure if this is valuable
        - Would allow me to expect that the return could respond to captured data names, even if it didn't match. Don't know if that is actually a benefit.
- [x] How can we select the part of the s-expression that contains the method name?
  - [x] Setup a failing test expecting a specific method name
    - Try a betterspecs.org style nested describe focusing on the `#method_name` capture data
      - 2 failures and 1 error
      - the error is because of `nil` return `NoMethodError`
  - [x] Expirement with `Sexp::Matcher#/` and see what we can find in the returned/yielded data.
    - Is an empty `MatchCollection` falsey?
      - Replace the call to `MATCHER.satisfy?(sexp)` with `MATCHER / sexp`
        - An empty `MatchCollection` is not falsey
        - Change the `if ... satisfy?` to `unless ... / ... empty?`
    - What is the first element of the collection if the `Sexp::Matcher` is only looking any sub-tree with a call to super?
      - Replace the `SexpMatchData.new(:some_method)` with a call to `binding.pry` and investigate
      - `MountainBike`
        - The first element is the whole s-expression input
        - The second element is the child sub-tree that contains the `super` call, in this case, the spares definition!
        - The third element is the call sub-tree of the method that contains the `super` call, chaining `merge` off of the return of `super`.
        - The last element was the matching subtree, just the `s(:zsuper)` for the call to `super` with no arguments
      - `RoadBike`
        - The second element is the child sub-tree that contains the `super(args)` call, in this case, a method definition!
        - The first element is the whole s-expression input.
        - The last element was the matching subtree, just the `s(:super, s(:lvar, :args))` for the call to `super(args)`.
  - [x] Iterate on the `SuperCaller::MATCHER` to include a method definition in the search if we need more context to find the method name.
    - If the `Sexp::Matcher` is changed to include a method definition containing a call to super, will the method definition sub-tree be the first element of the `MatchCollection` ?
      - It will likely be the last element, based on above observations.
      - However, maybe we could traverse a portion of the `MatchCollection` looking for the nearest method definition!
  - [x] `MatchCollection` also responds to `/`, what is the resulting `MatchCollection` if we drop the first and last elements and look for the first method definition?
    - I was surprised that I couldn't get `/` off of a new `MatchCollection` to work.
    - I achieved to use `#find` with `satisfy?` on a specific `Sexp::Matcher`
    - I can use `Array` unpacking/destructuring to grab the method name

-----

For now, our initial implementation of capturing data relevant to our matcher works. We likely need support for multiple matches within the same file. Still, I have a hunch that the affordances that `Sexp::Matcher#/` provides will enable composition of matchers and captured data, which I hope means it will remain relatively easy.

I did notice that `ruby_parser` isn't the only tool available to parse ruby into s-expressions or abstract syntax trees. `RuboCop` is built on the `parser` and `ast` gem. `parser` has node matching syntax which supports, among other things, capture groups. It could be an interesting exercise to refactor our current implementation to enable swapping in an alternate parser library.

For now, I'll continue setting up examples to test drive thie *make it work* implementation. The `Bicycle`, `MountainBike` and `RoadBike` examples could be filled in a bit more, so we can observe how our current implementation works when there are multiple methods that call `super` in a single file.

####### Capture groups iteration 2

**Observe**

- Our `satisfy?` method now leverages `Sexp::Matcher#/`
- `Sexp::Matcher#/` returns an `MatchCollection < Array` of sub-trees
- In the single result case, the `MatchCollection` elements are the shortest path from the root of the s-expression tree, to the leaf containing the matching s-expression.
- `Sexp::Matcher#search_each` or `Sexp#search_each` offers a recursive search through the tree.
- I believe that with the `MatchCollection` interface I could use `Enumerable#slice_after` to group tree walks into the paths to the matching result, with the last node being the specific match.
- [ ] Goal: support for classes/files with multiple methods calling super
- [ ] Goal: support for methods with multiple calls to super

**Orient**

- Is the call sequence for the block `#search_each` roughly equivalent to depth first search?
- What does a `MatchCollection` for a class with multiple methods that call `super` look like?
- What does a `MatchCollection` for a method that calls super multiple times look like, compared to the call sequence through `#search_each`?
- Now, we want the name of the method captured, but later we'll want the expression that includes `super`. If we include the method definition in the `Sexp::Matcher` to make capturing the method name easier, will we still need to take a second pass to find the `super` expressions to modify? Likewise with the superclass name.
- What are all the variations of method definitions that could match a `super` call? Which are the most common or idiomatic?

**Decide**

- Add all the methods that call super to our bikes classes and observe how the tests fail. Use `binding.pry` to observe how to group the matches to find the paths to the calls.
- Expand the captured data to include the superclass name and the `super` expression, to get more information for considering how to proceed at this iteration.
- Pull up the development console chain `#search_each` with `#each_with_index` and `puts` each call, compare to `#each_with_index` from a `MatchCollection`
- Write an `Sexp::Matcher` for `SuperCaller` that includes the method definition, and consider if to find the `super` expression or superclass name we could avoid additional passes at the s-expression with other `Sexp::Matcher`s
- Scaffold out a new project with the `aruba` acceptance tests and see what its like to use `parser` and it's node matchers, evaluate if their capture groups or parent nodes readily solve this, or just make the problem different.
- Ask Ryan Davis, author of `ruby_parser` and `SexpProcessor`

**Act**

###### Ask Ryan Davis, author of `ruby_parser` and `SexpProcessor`

I had been sharing a little bit of this work with SeattleRB, and the first reaction I got was surprise that I was figuring out `Sexp::Matcher`. When I describe my goal as trying to guess `Bicycle#spare_parts` from:

```ruby
class MountainBike < Bicycle
  def spare_parts
    super.merge({fork: "suspended"})
  end
end
```

Ryan was kind enough to point me towards [`MethodBasedSexpProcessor`](http://docs.seattlerb.org/sexp_processor/MethodBasedSexpProcessor.html) and after reading some of its, and the containing, source code, it has dawned on me that there's a different way to tackle this problem.

###### Capturing the Superclass name

**Observe**

- [`SexpProcessor`](http://docs.seattlerb.org/sexp_processor/SexpProcessor.html) sets up hook methods to call as it traverses an AST.
- The hook methods have a `process` and `rewrite` form, and they are specific to an `sexp_type`. IE: `process_call` or `rewrite_call`, or `process_zsuper` and `rewrite_zsuper`.
- Subclasses of `SexpProcessor` implement those hook methods to perform "processing" or rewriting when a node of a `sexp_type` is encountered.
- [`MethodBasedSexpProcessor`](http://docs.seattlerb.org/sexp_processor/MethodBasedSexpProcessor.html) implements `process_class`, `process_module`, `process_defn` and `process_defs` … if you choose to need those methods, then you *must* call `super` …
- `MethodBasedSexpProcessor` builds up a context stack, capturing the namespace as it descends into nested module(s), class(es) or singleton class, and finally, the method.
- [ ] Goal: include superclass in the context
- [ ] Goal: learn how to build an `SexpProcessor` subclass that'll pass the current tests: provide a reader to the method name that calls super
- [ ] Goal: add to the test coverage to capture the superclass name too
- [ ] Goal: finish the PR by providing a flag that outputs the captured data in `Superclass#method_name` notation.
- After calls to `MethodBasedSexpProcessor#in_method` the `MethodBasedSexpProcessor` instance is modified. The reader `MethodBasedSexpProcessor#method_locations` [returns a map of rdoc method signatures to filename and line numbers.](https://github.com/seattlerb/sexp_processor/blob/master/test/test_sexp_processor.rb#L340)
- [`MethodBasedSexpProcessor#signature`](https://github.com/seattlerb/sexp_processor/blob/master/test/test_sexp_processor.rb#L394) reduces the class and method stack to the current `ClassName#method_name`

**Orient**

- Is there a Ruby or Rdoc convention for including the superclass in a subclass's method signature?
- When a subclass of `MethodBasedSexpProcessor` encounters a `(class _ (const _) ___)` will `process_class` consume the type and subclass name, or will it call `process_const` after the `process_class` hook adds to the `MethodBasedSexpProcessor#class_stack` ?
  - it [will `yield`](https://github.com/seattlerb/sexp_processor/blob/master/lib/sexp_processor.rb#L607) the remaining expression in a call to `super` with a block
  - it [will continue proccessing](https://github.com/seattlerb/sexp_processor/blob/master/lib/sexp_processor.rb#L609) the remaining expression if `super` is called without a block
- Does it make sense to continue relying on `Sexp::Matcher#/` or can I refactor that completely to use a `MethodBasedSexpProcessor` subclass only?
  - A subclass of `MethodBasedSexpProcessor` can do this job
  - If `Sexp::Matcher` had "capture groups" like in `processor`/`ast` then could make a pattern that matches on class, captures the superclass name, matches on define method, captures the method name, and then captures the expression which includes `super` and that's your first pass.
- What I remember of reading the inline comments in [`lib/sexp_processor.rb`](https://github.com/seattlerb/sexp_processor/blob/master/lib/sexp_processor.rb) is that `rewrite_*` hooks rewrite, so [why does it look like `process_` hooks can too?](https://github.com/seattlerb/sexp_processor/blob/master/test/test_sexp_processor.rb#L109-L111)
  - Modern `SexpProcessor` design favours layering over preparing in a `rewrite_*` hook.
  - `ruby2c` or `ruby2ruby` probably contain the only valid examples of `rewrite_*` hooks.

**Decide**

- Test drive `#super_signature` on a sublcass of `MethodBasedSexpProcessor`
- Nerd party with Ryan Davis

**Act**

**Nerd party with Ryan Davis**

- What is the difference between process and rewrite?
  - rewrite: lighter weight for normalization
    - not meant for real work
    - IE: ensure `if` have both `true` and `false`
    - Old project `ParseTree` used it a lot
    - Somewhat in `ruby2c`
    - Is actually used in `ruby2ruby`
      - Probably only valid examples
    - New project: probably wouldn't use rewrite
      - Would have processor layers
  - process: for the real stuff
- `MethodBasedSexpProcessor#process_class`, does it hook `process_const` or does it handle that part of the s-expression?
  - shifts off the node type, shift off the class name
  - would process the superclass const
- There was a paper that tried getting from a diff to an ast transformation
- Maybe wrote a SexpDiff?
  - Racket has some Sexp stuff which might include Sexp diffs
  - Maybe port it over?
  - Racket project https://docs.racket-lang.org/sexp-diff/index.html

**Test drive `#super_signature` on a sublcass of `MethodBasedSexpProcessor`**

I started by choosing a small change, adding failing tests for `#method_name`. I don't mind continuing to support `#method_name` for this `SexpCliTools::Matchers::SuperCaller` class, but the thing that best captures what I need is `super_signature`

1. Refactor to `MethodBasedSexpProcessor`
  - [x] Change the superclass of `SexpCliTools::Matchers::SuperCaller` to `MethodBasedSexpProcessor`
    - need to `require 'sexp_processor'`
    - [ ] should I make this dependency explicit in the gemspec, or rely on the fact that `ruby_parser` depends on it?
  - [x] What is the entrypoint to a `SexpProcessor` ?
    - [`.new#process(sexp)`](https://github.com/seattlerb/sexp_processor/blob/master/test/test_sexp_processor.rb#L104-L111)
    - [x] How bad do the tests fail if I just use the default behaviour of `MethodBasedSexpProcessor#method_locations` ?
      - Obviously the hash is wrong, so lets just start by munging with the keys.
      - This is really close!
  - [ ] Implement the `process_defn` and `process_defs` methods to:
    - [x] call `super` passing in a block
    - [x] in the block, check if the rest of the expression matches a call to super
    - [ ] capture that method name in a `SexpMatchData`
    - [x] have the return value of `satisfy?` remain that `SexpMatchData` instance
2. Capture the superclass
  - [ ] Add failing test coverage for `super_signature`
  - [ ] Implement the `process_class` methods to:
    - call `super` passing in a block
    - in the block, check if the next expression is a `nil` or providing a superclass
    - add `Object` to the list of superclass if `nil`
    - add the superclass expression to the list of superclasses otherwise

#### Hook methods from super callers

#### Hook calls from super methods

