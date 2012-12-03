Gem::Specification.new do |spec|
  spec.name = 'switchvox'
  spec.version = '0.1.0'
  spec.platform = Gem::Platform::Ruby
  spec.summary = 'An interface with Switchvox API'
  spec.require_path = ['lib']
  spec.files = %w[
    Gemfile
    History.txt
    Manifest.txt
    README.rdoc
    Rakefile
    lib/switchvox.rb
    lib/switchvox/base.rb
    lib/switchvox/net_http_digest_auth.rb
    script/console
    script/destroy
    script/generate
    spec/spec_helper.rb
    spec/switchvox/base_spec.rb
    switchvox.gemspec
  ]
  spec.add_dependency('rake', '~> 10.0')
  spec.add_dependency('rspec', '~> 2.12')
  spec.add_dependency('ffaker', '~> 1.15')
  spec.add_dependency('webmock', '~> 1.9')
  spec.add_dependency('hoe', '>= 3.3')
end
