# server and db 
require 'sinatra'
require 'sinatra/reloader'
require './db/connection.rb'
require './db/active_record_init.rb'
require 'pg'
require 'active_record'

#debugging
require 'pry'

#data manipulation
require 'json'

#XLSX processing
require 'roo'
require 'spreadsheet'

#custom Report class for parsing 
require './public/ruby_classes/report.rb'

#data visualization
require 'chartkick'


get '/' do
	# pulling data if database is seeded
	sum = Month.sum(:total_sold)
	profit = Month.sum(:total_profit)

	top5profit = Product.order(total_profit: :desc).limit(5)
	top5sold = Product.order(total_sold: :desc).limit(5)

	erb :index, :locals => {sum: sum, profit: profit, top5profit: top5profit, top5sold: top5sold}
end

post '/reports' do
	# access the file at the tempfile, convert it using Roo since File.open/ read/ write doesn't convert .xlsx docs
	file = params["sales_sheet"][:tempfile].path
	# create new Report class using the new interface for the file
	report = Report.new(file)
	
	# update or create month table in database
	if Month.find_by({month: report.month}) != nil
		month_to_update = Month.find_by(month: report.month)
		month_to_update.total_sold += report.month_sum
		month_to_update.total_profit += report.month_profit
		month_to_update.save
	else 
		Month.create({month: report.month, total_sold: report.month_sum, total_profit: report.month_profit})
	end

	# update or create category table in database

	report.category_data.each do |category|
		if Category.find_by(name: category.keys[0]) != nil
			category_name = category.keys[0]
			category_to_update = Category.find_by(name: category_name)
			category_to_update.total_sold += category[category_name]["total_sold"]	
			category_to_update.total_profit += category[category_name]["total_profit"]
			category_to_update.save
		else
			category_name = category.keys[0]
			Category.create({name: category_name,total_profit: category[category_name]["total_profit"], total_sold: category[category_name]["total_sold"]})
		end
	end
	# // product create or update loop

	report.product_data.each do |product|
		if Product.find_by(name: product.keys[0]) != nil
			product_name = product.keys[0]
			product_to_update = Product.find_by(name: product_name)
			product_to_update.total_sold += product[product_name]["total_sold"]	
			product_to_update.total_profit += product[product_name]["total_profit"]
			product_to_update.save
		else

			product_name = product.keys[0]
			Product.create({name: product_name, total_profit: product[product_name]["total_profit"], total_sold: product[product_name]["total_sold"]})
		end
	end
	products = Product.all.to_a
	erb :upload, :locals => {products: products}
	
end

get '/reports' do
	
	erb :upload

end
