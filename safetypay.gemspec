
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "safetypay/version"

Gem::Specification.new do |spec|
  spec.name          = "safetypay"
  spec.version       = Safetypay::VERSION
  spec.authors       = ["Jasdeep S"]
  spec.email         = ["jasdeep@metawarelabs.com"]

  spec.summary       = %q{Ruby Client SDK for Safetypay}
  spec.description   = %q{Ruby Client SDK for Safetypay}
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "dry-struct", "~> 0.5.1"
  spec.add_runtime_dependency "dry-configurable", "~> 0.7.0"
  spec.add_runtime_dependency 'dry-core', '~> 0.4', '>= 0.4.3'
  spec.add_runtime_dependency "nori"
  spec.add_runtime_dependency "ox"
  spec.add_runtime_dependency "symbolized", "~> 0.0.1"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-html-matchers", "~> 0.9.1"
  spec.add_development_dependency "pry", "~> 0.11.3"
end
