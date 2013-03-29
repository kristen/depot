require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  fixtures :products

	test "product attributs must not be empty" do
		product = Product.new
		assert product.invalid?
		assert product.errors[:title].any?
		assert product.errors[:description].any?
		assert product.errors[:price].any?
		assert product.errors[:image_url].any?
	end

	test "produce price must be positive" do
		product = Product.new(title: "My Book Title",
													description: "yyy",
													image_url: "zzz.jpg")
		product.price = -1
		assert product.invalid?
		assert_equal Il8n.translate('activerecord.errors.messages.taken'),
			product.errors[:price].join("; ")

		product.price = 0
		assert product.invalid?
		assert_equal Il8n.translate('activerecord.errors.messages.taken'),
			product.errors[:price].join("; ")

		product.price = 1
		assert product.valid?
	end

	def new_product(image_url)
		Product.new(title: "My Book Title",
								description: "yyy",
								price: 1,
								image_url: image_url)
	end

	test "image url" do
		ok = %w{ fred.gif fred.jpg fred.png FRED.JPG FRED.Jpg http://a.b.c/x/y/z/fred.gif }
		bad = %w{ fred.doc fred.gif/more fred.gif.more }

		ok.each do |name|
			assert new_product(name).valid?, "#{name} shouldn't be invalid"
		end

		bad.each do |name|
			assert new_product(name).invalid?, "#{name} shouldn't be valid"
		end
	end

	test "product is not valid without a unique title" do
		product = Product.new(title: products(:ruby).title,
													description: "yyy",
													price: 1,
													image_url: "fred.gif")
		assert !product.save
		# assert_equal "has already been taken", product.errors[:title],join('; ')
		# In case you don't want to use the hard coded error message ...
		assert_equal Il8n.translate('activerecord.errors.messages.taken'), product.errors[:title].join(': ')
	end

	test "title must be at least 10 characters" do
		product = Product.new(description: "yyy",
													price: 1,
													image_url: "zzz.jpg")

		# less than 10 character test
		product.title = "hi"
		assert product.invalid?
		assert_equal Il8n.translate('activerecord.errors.messages.taken'), product.errors[:title].join(': ')
	
		# exactly 10 character test
		product.title = "characters"
		assert product.invalid?
		assert_equal Il8n.translate('activerecord.errors.messages.taken'), product.errors[:title].join(': ')
	
		# greater than 10 character test
		product.title = "This is a description that is longer than 10 characters"
		assert product.valid?
	end
end