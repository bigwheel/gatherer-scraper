require 'rspec'
require 'vcr'

require 'gatherer-scraper'

VCR.configure do |conf|
  conf.cassette_library_dir = 'spec/cassettes'
  conf.hook_into :fakeweb
  conf.configure_rspec_metadata!
end

RSpec.configure do |conf|
  conf.mock_with :rr
  conf.tty = true
  conf.treat_symbols_as_metadata_keys_with_true_values = true
end
