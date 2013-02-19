require "spec_helper"

describe Dict::CptController do
  it "should return an empty array on load" do
    get :index
    assigns(:cpts).should == []
  end

  it "should return one result when exact match is enabled" do
    get :index, :search_query => '406', :exact_match => 'true'
    assigns(:cpts).length.should == 1
  end

  it "should search by codeid" do
    random_record = Dict::Cpt.all.sample
    get :index, :search_query => random_record.code
    assigns(:cpts).include?(random_record).should == true
  end

  def get_snippet(string)
    return string if string.length < 20
    length = Random.rand(10..20)
    start = Random.rand(0..string.length - length)
    string[start..start + length]
  end

  it "should search by long description" do
    random_record = Dict::Cpt.all.sample
    get :index, :search_query => get_snippet(random_record.long_description)
    assigns(:cpts).include?(random_record).should == true
  end

  it "should search by medium description" do
    random_record = Dict::Cpt.all.sample
    get :index, :search_query => get_snippet(random_record.medium_description)
    assigns(:cpts).include?(random_record).should == true
  end

  it "should search by short description" do
    random_record = Dict::Cpt.all.sample
    get :index, :search_query => get_snippet(random_record.short_description)
    assigns(:cpts).include?(random_record).should == true
  end

  it "should show exact match first" do
    record = Dict::Cpt.where(:code => '936').first
    get :index, :search_query => record.code
    assigns(:cpts).first.should == record

    Dict::Cpt.all.sample(50).each do |record|
      get :index, :search_query => record.code
      assigns(:cpts).first.should == record
    end
  end
end
