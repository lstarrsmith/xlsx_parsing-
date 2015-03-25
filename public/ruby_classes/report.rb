
#### Caveat this Class with the fact that it's dependent on the file structure. For later versions we will need to create a class to parse the file and find where certain pieces of information exist. Right now, this class is set up to match the example file rows exactly. Files that are formatted differently will not read correctly. 


class Report
	def initialize(report_xlsx)
		# sourced from: http://stackoverflow.com/questions/15460746/how-to-read-an-xlsx-or-xls-file-from-a-url for reading .xlsx properly with Roo
		@report = Roo::Excelx.new(report_xlsx, nil, :ignore)
	end

	def raw_output
		puts @report
	end
	def month
		@month = @report.row(5)[0].mon       # date object 
		return @report.row(5)[0].mon
	end

	# create a hash with all the products listed out
	def create_product_type_hash
		@product_type = Hash.new

		((@report.first_row+6)..@report.last_row).each do |row_num|
			if @report.row(row_num)[0].to_i == 0 
				@product_type[(s.row(row_num)[0])] = []
			end        ## to_i converts letters to 0, so this catches all the product_type names                   
		end 
	end

	#calculate the total units sold for each month
	def month_sum
		sum = 0
		((@report.first_row+6)..@report.last_row).each do |row_num|
			if @report.row(row_num)[0].to_i > 0 
				sum += @report.row(row_num)[2].to_i
			end
		end
		return sum

	end

	# calculate the total profit for each month
	def month_profit
		profit = 0
		((@report.first_row+6)..@report.last_row).each do |row_num|
			if @report.row(row_num)[0].to_i > 0 
				profit += (@report.row(row_num)[4].to_i - @report.row(row_num)[3].to_i)
			end
		end
		return profit
	end

	

	def category_data
		category_data = []
		((@report.first_row+6)..@report.last_row).each do |row_num|
			if @report.row(row_num)[0].to_i == 0 
				category_data.push({@report.row(row_num)[0] => {"total_sold" => 0, "total_profit" => 0}})
			end

		end

		counter = 0
		((@report.first_row+7)..@report.last_row).each do |row_num|
			if @report.row(row_num)[0].to_i == 0 
				counter += 1
			else
				category_name = category_data[counter].keys[0]
				category_data[counter][category_name]["total_profit"] += (@report.row(row_num)[4].to_i - @report.row(row_num)[3].to_i)
				category_data[counter][category_name]["total_sold"] += @report.row(row_num)[2].to_i

			end
		end
		return category_data

	end

	def product_data
		product_data = []
		((@report.first_row+6)..@report.last_row).each do |row_num|
			if @report.row(row_num)[0].to_i > 0
				product_name = @report.row(row_num)[1]
				product_sum = @report.row(row_num)[2].to_i
				product_profit = (@report.row(row_num)[4].to_i - @report.row(row_num)[3].to_i)
				product_data.push({product_name => {"total_sold" => product_sum, "total_profit" => product_profit}})
			end
		end
		return product_data
	end
end




######### IDEALLY WE SPLIT PROFIT AND SUM INTO TWO SEPARTE METHODS, BUT IT'S MORE EFFICIENT TO WRITE TO THE DATABASE USING THIS CONSOLIDATED CLASS STRUCTURE. THE METHODS BELOW ARE SAVED FOR FUTURE REFACTORING


# def category_sum
# 		## create an array of all category types with total sum
# 		category_sums = []
# 		((@report.first_row+6)..@report.last_row).each do |row_num|
# 			if @report.row(row_num)[0].to_i == 0 
# 				category_sums.push({@report.row(row_num)[0] => 0})
# 			end

# 		end
		
# 		# loop through the report to add to the sum based on the total amount sold
# 		counter = 0
# 		# --- first row + 7 instead of 6 to skip first category name ---------------------#
# 		((@report.first_row+7)..@report.last_row).each do |row_num|
# 			if @report.row(row_num)[0].to_i == 0 
# 				counter += 1
# 			else
# 				category_name = category_sums[counter].keys[0]
# 				category_sums[counter][category_name] += @report.row(row_num)[2].to_i
# 			end
# 		end
# 		return category_sums

# 	end


	# def category_profit
	# 	category_profits = []
	# 	((@report.first_row+6)..@report.last_row).each do |row_num|
	# 		if @report.row(row_num)[0].to_i == 0 
	# 			category_profits.push({@report.row(row_num)[0] => 0})
	# 		end

	# 	end

	# 	# loop through the report to add to the sum based on the total amount sold
	# 	counter2 = 0
	# 	# --- first row + 7 instead of 6 to skip first category name ---------------------#
	# 	((@report.first_row+7)..@report.last_row).each do |row_num|
	# 		if @report.row(row_num)[0].to_i == 0 
	# 			counter2 += 1
	# 		else
	# 			category_name = category_profits[counter2].keys[0]
	# 			category_profits[counter2][category_name] += (@report.row(row_num)[4].to_i - @report.row(row_num)[3].to_i)
	# 		end
	# 	end
	# 	return category_profits

	# end


	# def product_sum
	# 	product_sums = []
	# 	((@report.first_row+6)..@report.last_row).each do |row_num|
	# 		if @report.row(row_num)[0].to_i > 0
	# 			product_sum_name = @report.row(row_num)[1]
	# 			product_sum_sum = @report.row(row_num)[2].to_i
	# 			product_sums.push({product_sum_name => product_sum_sum})
	# 		end
	# 	end
	# 	return product_sums
	# end

	# def product_profit
	# 	product_profits = []
	# 	((@report.first_row+6)..@report.last_row).each do |row_num|
	# 		if @report.row(row_num)[0].to_i > 0
	# 			product_profit_name = @report.row(row_num)[1]
	# 			product_profit_profit = (@report.row(row_num)[4].to_i - @report.row(row_num)[3].to_i)
	# 			product_profits.push({product_profit_name => product_profit_profit})
	# 		end
	# 	end
	# 	return product_profits
	# end