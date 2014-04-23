# -*- encoding: utf-8 -*-
require File.expand_path("../lib/html/pipeline/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "html-pipeline-linuxfr"
  gem.version       = HTML::Pipeline::VERSION
  gem.license       = "MIT"
  gem.authors       = ["Ryan Tomayko", "Jerry Cheung", "Bruno Michel"]
  gem.email         = ["ryan@github.com", "jerry@github.com", "bmichel@menfin.info"]
  gem.description   = %q{LinuxFr.org HTML processing filters and utilities, adapted from those of GitHub}
  gem.summary       = %q{Helpers for processing content through a chain of filters}
  gem.homepage      = "https://github.com/nono/html-pipeline-linuxfr"

  gem.files         = `git ls-files`.split $/
  gem.test_files    = gem.files.grep(%r{^test})
  gem.require_paths = ["lib"]

  gem.add_dependency "nokogiri",        "~> 1.4"
  gem.add_dependency "redcarpet",       "~> 3.1"
  gem.add_dependency "pygments.rb",     "~> 0.5"
  gem.add_dependency "sanitize",        "~> 2.0"
  gem.add_dependency "escape_utils",    "~> 1.0"
  gem.add_dependency "activesupport",   "~> 4.0"
  gem.add_dependency "patron",          "~> 0.4"
end
