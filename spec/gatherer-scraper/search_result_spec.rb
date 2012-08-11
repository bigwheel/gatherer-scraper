require 'spec_helper'

describe GathererScraper::SearchResult do
  context 'with "Magic 2013" set' do
    before { @m13set = described_class.new(set: 'Magic 2013') }
    describe '#multiverseids', :vcr => { :cassette_name => 'gatherer/search', :record => :new_episodes } do
      subject { @m13set.multiverseids }
      its(:length) { should == 234 }
      it '\'s all elements should be unique' do
        subject.uniq.length.should == subject.length
      end
    end
  end
end
