# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "fluent-plugin-mysql-table"
  gem.version       = "0.0.1"
  gem.authors       = ["a4t"]
  gem.email         = ["onishishigure@gmail.com"]
  gem.summary       = "Mysql change monitaring"
  gem.description   = "Mysql change monitaring"
  gem.homepage      = ""
  gem.license       = "MIT"

  gem.files         = `git ls-files -z`.split("\x0")
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "fluentd", "~> 0.12"
  gem.add_dependency "mysql2",  "~> 0.3.11"

  gem.add_development_dependency "bundler", "~> 1.7"
  gem.add_development_dependency "rake", "~> 10.0"
  gem.add_development_dependency "test-unit", ">= 3.0.8"
end
