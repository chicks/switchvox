Gem::Specification.new do |spec|
  spec.name = 'switchvox'
  spec.author = 'Carl Hicks'
  spec.version = '0.1.0'
  spec.platform = Gem::Platform::RUBY
  spec.summary = 'An interface with Switchvox API'
  spec.homepage = 'https://github.com/chicks/switchvox'
  spec.description = 'Basic interface to allow ruby applications to interface with the SwitchVox XML API'
  spec.require_path = 'lib'
  spec.files = File.read('Manifest.txt').split("\n")

  spec.add_development_dependency('rake', '~> 10.0')
  spec.add_development_dependency('rspec', '~> 2.12')
  spec.add_development_dependency('ffaker', '~> 1.15')
  spec.add_development_dependency('webmock', '~> 1.9')
end
