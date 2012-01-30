# XcodeBuild: A comprehensive xcodebuild wrapper and output parser

[![Build Status](https://secure.travis-ci.org/lukeredpath/xcodebuild.png)](http://travis-ci.org/lukeredpath/xcodebuild])

When ready, this gem will provide a simple means of executing `xcodebuild` using the Rake utility.

In addition, it will give users full control over how the build is output, by allowing the use of special build formatters; some formatters will be built-in, otherwise custom formatters can be created easily.

As well as supporting translation of `xcodebuild` output for simple build/clean commands, functionality can be extended by adding new "translations", that can be used to parse other outputs such as output from testing frameworks that integrate with the build process.

This is currently a work in progress. If you want to get an idea of how it works, read the source code. There is no documentation as yet but there is a comprehensive spec suite (acceptance specs coming soon).

