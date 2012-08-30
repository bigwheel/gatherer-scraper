require 'spec_helper'

module GathererScraper
describe GathererScraper::SearchResult do
  CardProperty::SUPPORTING_EXPANSION_LIST.each do |cardset|
    cardset = cardset.to_s
    context "with '#{cardset}' card set",
      vcr: { :cassette_name => "search/#{cardset}", :record => :new_episodes } do
      subject { GathererScraper::search_result(set: cardset) }

      it('should accept') { expect { subject }.not_to raise_error }

      its(:length) { should_not == 0 }
    end
  end
end
end
