class Dict::CptController < ApplicationController
  ALL_FIELDS = ['code','long_description','medium_description','short_description']
  SHORT_FIELDS = ['code','short_description']
  
  def index
    query = params[:search_query]
    exact_match = (params[:exact_match] || 'false').to_sym
    if query == nil
      @cpts = []
    else
      if exact_match == :true
        conditions = create_condition_array(SHORT_FIELDS,'=',query)
      else
        conditions = create_condition_array(ALL_FIELDS,'like', "%#{query}%" )
      end
      @cpts = Dict::Cpt.find(:all, :conditions => conditions )
      move_exact_to_front(query) if exact_match != :true
    end
  end

  protected
  def move_exact_to_front(query)
    #moves any record whoose code matches the query exactly to position zero
    @cpts.sort! { |a,b| comparison_to_i(b.code,query) <=> comparison_to_i(a.code,query) }
  end

  def create_condition_array(fields, operator, value)
    query = fields.map { |field| "#{field} #{operator} ?"}.join(' or ') 
    [query] + [value] * fields.length
  end

  def comparison_to_i(string_one, string_two)
    #false.object_id is always 0 and true.object_id is always 2
    (string_one == string_two).object_id
  end
end
