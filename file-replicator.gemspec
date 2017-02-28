# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'file_replicator/version'

Gem::Specification.new do |spec|
  spec.name          = 'file-replicator'
  spec.version       = FileReplicator::VERSION
  spec.authors       = ['Viktor (Icon) VAD']
  spec.email         = ['vad.viktor@gmail.com']

  spec.summary       = %q{Split and join files in binary mode}
  spec.description   = %q{Command line utility that can split files into chunks, join them together. All is done in binary mode making it encoding independent.}
  spec.homepage      = 'https://github.com/vadviktor/file-replicator'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'slop', '4.4.1'
  spec.add_dependency 'pastel', '0.7.0'
  spec.add_dependency 'ruby-progressbar', '1.8.1'

  spec.add_development_dependency 'bundler', '1.13.7'
  spec.add_development_dependency 'rake', '11.3.0'
  spec.add_development_dependency 'minitest', '5.9.1'
  spec.add_development_dependency 'minitest-reporters', '1.1.12'
end
