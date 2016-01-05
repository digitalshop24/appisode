class Show < ActiveRecord::Base
  def self.search(query)
    where('lower(additional_field) like lower(:query) or lower(russian_name) like lower(:query)', { query: "%#{query}%" })
  end
end
