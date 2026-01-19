---
title: "Default and Bundled Gems"
date: 2026-01-18 15:36:40 -0500
categories: ruby
---

# Default and Bundled Gems

Have you ever come across a warning message like this when running a Ruby script?
```
warning: logger was loaded from the standard library, but will no longer be part of the default gems starting from Ruby 3.5.0.
You can add logger to your Gemfile or gemspec to silence this warning.
```

When you see something like this you might wonder, what is a \"default gem\" anyway? Why is it changing with the next version of Ruby? Why does it matter to me?
Or at least those are the questions that I asked when I saw this error. Here's what I found out.

## Built in Functionality in Ruby

Ruby is a very rich language with lots of built-in functionality that is provided \"out of the box\" for us to use. Often this breadth of functionality is referred to as Ruby's *Standard Library*.
However, there are some differences about how this Standard Library is organized and provided to us as developers.

There are 3 main divisions of provided functionality in Ruby:
1. Ruby core classes and modules
2. Default Gems
3. Bundled Gems

## Ruby Core Classes and Modules
The core classes and modules are the fundamental building blocks of the Ruby language itself. These include classes like `String`, `Array`, `Hash`, and modules like `Enumerable` and `Comparable`.
These core classes and modules are always available to us without needing to `require` anything to use them in our code.

## Default Gems

Default gems are gems that are included with Ruby installations and can be updated upon each release. These gems are maintained by the Ruby core team. They cannot be uninstalled, but to use them you need to `require` them in your code.

The idea of having these default gems is to allow the Ruby core team to update and improve certain libraries independently of the main Ruby release cycle. 

Some examples of the current default gems are:
- bundler
- date
- json
- singleton

## Bundled Gems

Bundled gems are also gems that are included with Ruby installations, however these gems are optional and can be uninstalled if desired. Like default gems, to use them you need to `require` them in your code.
Some examples of bundled gems are:
- benchmark
- csv
- irb
- minitest
- rake


For the full list of default and bundled gems, check out the [official Ruby documentation](https://docs.ruby-lang.org/en/4.0/standard_library_md.html#label-Ruby+Standard+Library)


## What do warnings like this mean?

When you see a warning like the one at the top of this post, it means that the gem in question is currently a default gem, but it will be removed from the default gems in a future version of Ruby.
This means that code used to be able to assume that the gem was always available, and thus didn't need to include it in the Gemfile or gemspec. However, once the gem is no longer a default gem, code that uses it will need to explicitly include it as a dependency.

## Why do these changes happen?

The Ruby core team periodically updates which gems are included as the default gems and/or bundled gems. These changes ensure that the gems included with Ruby are still relevant and useful to the majority of Ruby developers.

Another factor is maintainability. it seems that it is much easier from a maintenance perspective to have fewer default gems. In fact the Ruby team refers to a change from a default gem to a bundled gem as a \"promotion\".
The reasoning here is due to issues with the core Ruby repository needing to "sync" status with the individual gem repositories for default gems, which can lead to complications when trying to release new versions of Ruby. 
Moving more gems to bundled gems reduces this friction as they are less tightly coupled to the Ruby release process.

If you are interested in learning more about these issues, you can check out this [discussion](https://bugs.ruby-lang.org/issues/19351#note-16) regarding the 3.3 release of Ruby.