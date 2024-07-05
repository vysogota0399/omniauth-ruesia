lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name        = "omniauth-ruesia"
  spec.version     = File.read('VERSION')
  spec.authors     = [""]
  spec.email       = [""]
  spec.homepage    = "https://github.com/vysogota0399/omniauth-ruesia"
  spec.summary     = "Summary of Ruesia."
  spec.description = "Description of Ruesia."
  spec.licenses    = %w[MIT]

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/vysogota0399/omniauth-ruesia"
  spec.metadata["changelog_uri"] = "https://github.com/vysogota0399/omniauth-ruesia/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end
  spec.add_development_dependency 'rspec'
  spec.add_runtime_dependency 'omniauth'
  spec.add_runtime_dependency 'omniauth-rails_csrf_protection'
  spec.add_runtime_dependency 'omniauth-oauth2'
end
