class Show < ActiveRecord::Base
  default_scope { order('created_at DESC') }	
	def self.search(query)
		where('lower(name) like lower(:query) or lower(russian_name) like lower(:query)', { query: "%#{query}%" })
  end

end
