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

#templating system
require 'mustache'

#custom Report class for parsing 
require './public/report.rb'

#data visualization
require 'chartkick'


get '/' do
	html = File.read("./views/index.html")
	html
end

post '/reports' do
	report = Report.new(params["sales_sheet"])
	
	# update or create month table
	if Month.find_by({month: report.month}) != nil
		month_to_update = Month.find_by(month: report.month)
		month_to_update.total_sold += report.month_sum
		month_to_update.total_profit += report.month_profit
		month_to_update.save
	else 
		Month.create({month: report.month, total_sold: report.month_sum, total_profit: report.month_profit})
	end

	# update or create category table

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
	erb :dashboard, :locals => {products: products}
	
end

get '/reports' do
	months = Month.order(total_sold: :desc).to_a
	categories = Category.order(total_sold: :desc).to_a
	products = Product.order(total_sold: :desc).to_a
	erb :dashboard, :locals => {products: products}
end


# post '/results' do
# 	 # class declaration example
# 	 report = Roo::Excelx.new(params["sales_sheet"])
	 

# 	binding.pry

# 	 s = Roo::Excelx.new(params["sales_sheet"])  
# 	 month = s.row(5)
# 	headers_array = s.row(6)

# 	beverages = s.row(7)

# 	# gather product types

# 	product_type = Hash.new

# 	((s.first_row+6)..s.last_row).each do |row_num|
# 		if s.row(row_num)[0].to_i == 0 
# 			product_type[(s.row(row_num)[0])] = []
# 		end        ## to_i converts letters to 0, so this catches all the product_type names                   
# 	end   

# 	## insert products into product types
# 	counter = 0

# 	((s.first_row+6)..s.last_row).each do |row_num|
# 		if s.row(row_num)[0].to_i == 0 
# 			counter += 1
# 		else
# 			# puts product_type.keys[counter-1]
			
# 			product_type[product_type.keys[counter-1]].push({"item_code" => s.row(row_num)[0], "description" => s.row(row_num)[1], "units_sold" => s.row(row_num)[2], "buying_price" => s.row(row_num)[3], "selling_price" => s.row(row_num)[4]})             # hardcoded headers for now, but will pull from headers array ideally. But I feel this enhances short-term readability.
# 		end
# 	end

# 	product_type.to_json


# end

# ---------------------------------------------------
# ---------------------------------------------------
# ---------------------------------------------------
#  s = Roo::Excelx.new(params["sales_sheet_file"])    
# s = Roo::Excelx.new("./MonthlySalesReport_MAY.xlsx") 

# month = s.row(5)
# headers_array = s.row(6)

# beverages = s.row(7)

# # gather product types

# product_type = Hash.new

# ((s.first_row+6)..s.last_row).each do |row_num|
# 	if s.row(row_num)[0].to_i == 0 
# 		product_type[(s.row(row_num)[0])] = []
# 	end        ## to_i converts letters to 0, so this catches all the product_type names                   
# end   

# ## insert products into product types
# counter = 0

# ((s.first_row+6)..s.last_row).each do |row_num|
# 	if s.row(row_num)[0].to_i == 0 
# 		counter += 1
# 	else
# 		# puts product_type.keys[counter-1]
		
# 		product_type[product_type.keys[counter-1]].push({"item_code" => s.row(row_num)[0], "description" => s.row(row_num)[1], "units_sold" => s.row(row_num)[2], "buying_price" => s.row(row_num)[3], "selling_price" => s.row(row_num)[4]})             # hardcoded headers for now, but will pull from headers array ideally. But I feel this enhances short-term readability.
# 	end
# end

# binding.pry





# arr_of_arrs = CSV.read("./MonthlySalesReport_JUNE.csv")

# binding.pry

# ----------xlsx2json

# json_path = './test.json'
# excel_path = './MonthlySalesReport_JUNE.xlsx'

# sheet_number = 0

# header_row_number = 8

# Xlsx2json::Transformer.execute excel_path, sheet_number, json_path, header_row_number: header_row_number

# JSON.parse(File.open(json_path).read) 


# -----------------dullard ***
# workbook = Dullard::Workbook.new "./MonthlySalesReport_JUNE.xlsx"
# workbook.sheets[0].rows.each do |row|
#   puts row 
# end

# -----------excel2csv **

# excel2csv "./MonthlySalesReport_JUNE.xlsx"


# ------ roo 


# s = Roo::Excelx.new("./MonthlySalesReport_JUNE.xlsx")
# s.each_row_streaming do |row|
#     puts row.inspect # Array of Excelx::Cell objects
# end