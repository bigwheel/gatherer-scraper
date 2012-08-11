# -*- encoding: utf-8 -*-
require File.expand_path('../lib/gatherer-scraper/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["bigwheel"]
  gem.email         = ["k.bigwheel+eng@gmail.com"]
  gem.description   = <<-EOS
Scrape Gatherer, Magic: The Gathering official card database
(http://gatherer.wizards.com/) and extract object form card data.
EOS
  gem.summary       = %q{Scrape Gatherer(MTG card database)}
  gem.homepage      = "http://github.com/bigwheel/gatherer-scraper"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "gatherer-scraper"
  gem.require_paths = ["lib"]
  gem.version       = GathererScraper::VERSION

  gem.add_dependency 'activemodel', '~>3.2.0'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rr'
  gem.add_development_dependency 'vcr'
  gem.add_development_dependency 'nokogiri'
end
