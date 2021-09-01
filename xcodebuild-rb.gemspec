# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "xcodebuild-rb"
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Luke Redpath"]
  s.date = "2012-02-10"
  s.email = "luke@lukeredpath.co.uk"
  s.executables = ["rbxcb"]
  s.extra_rdoc_files = ["README.md", "CHANGES.md"]
  s.files = ["LICENSE", "README.md", "bin/rbxcb", "spec/build_task_spec.rb", "spec/output_translator_spec.rb", "spec/reporting", "spec/reporting/build_reporting_spec.rb", "spec/reporting/clean_reporting_spec.rb", "spec/spec_helper.rb", "spec/translations", "spec/translations/building_translations_spec.rb", "spec/translations/cleaning_translations_spec.rb", "lib/xcode_build", "lib/xcode_build/build_action.rb", "lib/xcode_build/build_step.rb", "lib/xcode_build/formatters", "lib/xcode_build/formatters/progress_formatter.rb", "lib/xcode_build/formatters.rb", "lib/xcode_build/output_translator.rb", "lib/xcode_build/reporter.rb", "lib/xcode_build/reporting", "lib/xcode_build/reporting/build_reporting.rb", "lib/xcode_build/reporting/clean_reporting.rb", "lib/xcode_build/tasks", "lib/xcode_build/tasks/build_task.rb", "lib/xcode_build/tasks.rb", "lib/xcode_build/translations", "lib/xcode_build/translations/building.rb", "lib/xcode_build/translations/cleaning.rb", "lib/xcode_build/translations.rb", "lib/xcode_build/utilities", "lib/xcode_build/utilities/colorize.rb", "lib/xcode_build.rb", "lib/xcodebuild.rb", "CHANGES.md"]
  s.homepage = "http://github.com/lukeredpath/xcodebuild-rb"
  s.rdoc_options = ["--main", "README.md"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.11"
  s.summary = "Build Xcode projects using Rake"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<state_machine>, ["~> 1.1.2"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<rake>, ["~> 0.9.2.2"])
      s.add_development_dependency(%q<rdoc>, "~> 6.3")
      s.add_development_dependency(%q<guard-rspec>, [">= 0"])
      s.add_development_dependency(%q<growl>, [">= 0"])
      s.add_development_dependency(%q<timecop>, [">= 0"])
    else
      s.add_dependency(%q<state_machine>, ["~> 1.1.2"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<rake>, ["~> 0.9.2.2"])
      s.add_dependency(%q<rdoc>, "~> 6.3")
      s.add_dependency(%q<guard-rspec>, [">= 0"])
      s.add_dependency(%q<growl>, [">= 0"])
      s.add_dependency(%q<timecop>, [">= 0"])
    end
  else
    s.add_dependency(%q<state_machine>, ["~> 1.1.2"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<rake>, ["~> 0.9.2.2"])
    s.add_dependency(%q<rdoc>, "~> 6.3")
    s.add_dependency(%q<guard-rspec>, [">= 0"])
    s.add_dependency(%q<growl>, [">= 0"])
    s.add_dependency(%q<timecop>, [">= 0"])
  end
end
