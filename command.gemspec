# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "command"
  s.version = "0.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Alessandro Berardi,,,"]
  s.date = "2011-09-16"
  s.email = "berardialessandro@gmail.com"
  s.extra_rdoc_files = ["README"]
  s.files = ["Gemfile.lock", "Rakefile", "README", "Gemfile", "command.gemspec", "spec/command_spec.rb", "lib/command/proc_command.rb", "lib/command/command.rb", "lib/command.rb"]
  s.homepage = "http://github.com/AlessandroBerardi/action_profiler"
  s.rdoc_options = ["--main", "README"]
  s.require_paths = ["lib"]
  s.requirements = ["rtree gem from https://github.com/AlessandroBerardi/rtree"]
  s.rubygems_version = "1.8.10"
  s.summary = "Ruby implementation of the composite commands pattern"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rtree>, ["~> 0.3.3"])
      s.add_development_dependency(%q<rspec>, ['>= 2.14.0.rc1'])
    else
      s.add_dependency(%q<rtree>, ["~> 0.3.3"])
      s.add_dependency(%q<rspec>, ['>= 2.14.0.rc1'])
    end
  else
    s.add_dependency(%q<rtree>, ["~> 0.3.3"])
    s.add_dependency(%q<rspec>, ['>= 2.14.0.rc1'])
  end
end
