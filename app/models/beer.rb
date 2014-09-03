class Beer < ActiveRecord::Base
	belongs_to :brewer
	belongs_to :style
	belongs_to :location
	belongs_to :format
	
	validates :name, length: { maximum: 100 }, presence: true, uniqueness: true
	validates :brewer_id, presence: true
	validates :format_id, presence: true
	validates :style_id, presence: true
	validates :location_id, presence: true
	validates :price, presence: true, numericality: true
	validates :abv, presence: true, numericality: true
	validates :freight, presence: true, numericality: true

	after_save :update_file

	def pricefor(serving_size, method)
		markup = 0.4
		tax = 1.15
		# defined here so it's in scope for after the each
		price = 0
		price_per_litre = ( self.price / self.format.size ) / markup * tax
		# We assume here that a handle is 500ml
		price_per_handle = price_per_litre / 2
		# We do the redundant "/ 10" math just to clarify the value is in L (ie 285ml == 0.285L)
		case method
		when :handle # 500ml
			price = price_per_handle
		when :half # 285ml
			price = price_per_handle / 0.285 / 10
		when :benny # 400ml
			price = price_per_handle / 0.400 / 10
		when :glass # 300ml
			price = price_per_handle / 0.300 / 10
		when :rigger_small # 1500 ml
			price = price_per_handle / 1.5 / 10
		else # 2000 ml
			price = price_per_handle / 2 / 10
		end
		# Warning, if there's no match in the method db table
		# it'll calculate a cost of $0, a validation is added
		# in the beers_helper so we don't give away free beer
		price.round(1)
	end

	class <<self
		
		def ontap
			self.joins(:location).where(locations: { status: ['LOW','SERVING'] }).includes(:brewer, :format)
		end

		def search(search, page)
			order('location_id').where('name LIKE ?', "%#{search}%").paginate(page: page, per_page: 10)
		end

		def menu
			self.joins(:location).where(locations: { status: ['INBOUND','STOCK','SERVING','NEXT'] }).includes(:brewer)
		end

		def empties
			self.joins(:location).where(locations: { status: ['EMPTY','RETURNING'] }).includes(:brewer)
		end

	end

	def update_file
		path = File.join(Rails.root, 'app', 'tmp', 'clubfare', 'beer_updated')
		data = "Record Updated"
		File.open(path, 'w') do |f|
			f.write(data)
		end
	end

end
