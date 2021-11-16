# sexp_cli_tools
Educational project exploring the utility in searching and manipulating codebases using S-expressions.

## Inspiration

I once found wide spread use of a "magical" Ruby method which was unnecessary. The intent of this method was to relieve the developer from the repeatition of setting instance variables from method parameters. How this magic method did this was difficult to understand for most. Upon examining this method, I noticed it made costly calls to do at run time what could have been done by a developer with a keyboard, or if you wanted to, with code at load time.

I was new to the team and project, and because the use of this method was wide spread, I wanted a systematic and repeatable approach to refactoring it out of existence so that I and my new colleagues could trust the widespread change.

## Concrete Examples We Can All Learn From

### Decoupling Subclasses Using Hook Messages

In Chapter 6 of Practical Object-Oriented Design in Ruby by Sandi Metz, part of the discussion is focused on finding the ideal coupling between child and parent classes. One proposal introduced in that chapter is to use hook methods, instead of calling super.

Lets imagine a scenario where we have achieved total consensus in an organization, and the new direction is to dogmatically use hook methods, instead of calling super.

#### Goal

- Replace methods that call super with a hook method
- Modify parent classes implementation of the supered method to call hook methods

#### Initial state

We will begin with the classes [`Bicycle`](test/fixtures/coupling_between_superclasses_and_subclasses/bicycle.rb), [`RoadBike`](test/fixtures/coupling_between_superclasses_and_subclasses/road_bike.rb) and [`MountainBike`](test/fixtures/coupling_between_superclasses_and_subclasses/mountain_bike.rb). We will build them up to  the state from **Managing Coupling Between Superclasses and Subclasses** until we can recognize the important parts of the "discernible pattern."

#### Milestones

Things we must be able to interogate about this code:
- Which are the children, and which is the parent class?
- Which methods call super, and which is the method that responds to super?
- What in each method that calls super needs to be in the respective hook method?
- What change needs to occur in the method responding to super to leverage the hook methods?

#### Finding the parent of child classes

#### Methods that call super, and methods that are super

#### Hook methods from super callers

#### Hook calls from super methods

