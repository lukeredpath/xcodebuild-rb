# xcodebuild-rb: Building Xcode projects with Rake

[![Build Status](https://secure.travis-ci.org/lukeredpath/xcodebuild-rb.png)](http://travis-ci.org/lukeredpath/xcodebuild-rb])

xcodebuild-rb is a RubyGem that provides a Ruby interface to the `xcodebuild` utility that ships with Xcode in the form of a series of Rake tasks. This gem only supports Xcode 4 (you can try it with 3.x, but YMMV). It makes it simple to run your builds from the command line, especially on remote machines such as Continuous Integration servers.

In addition, it provides configurable output parsing that enables better formatting of Xcode build results and eventually, test results. This is done through a series of output translations, reporters and formatters. All of this can be extended with a bit of Ruby knowledge (more on that soon).

This library is still under development but it should be more or less usable out of the box.

## Getting started

After installing the gem, you need to create a `Rakefile` in the root of your project if you don't already have one. If you aren't familiar with `rake`, you can think of it as a Ruby equivalent to `make`. You can find out more about `rake` [here](http://rake.rubyforge.org/).

A simple Rakefile will look like this:

    require 'rubygems'
    require 'xcodebuild-rb'
    
    XcodeBuild::Tasks::BuildTask.new

With only those three lines, you will now have access to a variety of tasks such as clean and build. A full list of tasks can be viewed by running `rake -T`:

    $ rake -T
    rake xcode:build       # Builds the specified target(s).
    rake xcode:clean       # Cleans the build using the same build settings.
    rake xcode:cleanbuild  # Builds the specified target(s) from a clean slate.
    
## Configuring your tasks
    
When you run `rake xcode:build`, `xcodebuild` will be invoked without any arguments, which will in turn cause the default build to run. For this to be more useful, we need to configure the task. We could, for instance, configure the target and configuration:

    XcodeBuild::Tasks::BuildTask.new do |t|
      t.target = "MyApp"
      t.configuration = "Release"
    end

When you run the rake tasks provided, the default behaviour is to simply output the exact output from `xcodebuild`. However, `xcodebuild-rb` can go one better and allow you to configure custom formatters that change the way the build output is displayed. Some formatters are built-in, or you can write your own.

For instance, we could use the "progress" formatter that ships with `xcodebuild-rb`. Anybody who is used to the output of Ruby's Test::Unit library or RSpec library will be familiar with this.

    XcodeBuild::Tasks::BuildTask.new do |t|
      t.formatter = XcodeBuild::Formatters::ProgressFormatter.new
    end
    
Now when you run your build, your output will look something like this:

    Building target: ExampleProject (in ExampleProject.xcproject)
    =============================================================

    Configuration: Release
    ..............

    Finished in 2.226883 seconds.
    Build succeeded.

## License

This library is licensed under the [MIT license](http://en.wikipedia.org/wiki/MIT_License).