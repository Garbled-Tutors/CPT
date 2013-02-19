require "spec_helper"

describe "CPT Search", :type=>:request, :js => true do
  it "should not display records when search is empty" do
    visit ''
    page.should have_content("There are no records")
  end

  it "should display a single record when exact match is set" do
    visit ''
    check('exact_match')
    fill_in('search_query', :with => '100')
    find_button('Search').click
    page.find('table#results').all('tr').length.should == 2
  end

end
