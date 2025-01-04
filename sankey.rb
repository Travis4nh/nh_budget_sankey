#!/usr/bin/env ruby

require 'csv'

# Example of parsing a CSV file
csv_file_path = './Governor-FY24_25-Recommended-Budget.csv'

header_row_number = 5
headers = []

rows = CSV.read(csv_file_path)

rows.each_with_index do |row, ii|
  # puts "row = #{row}"
  if ii == header_row_number
    headers = row
    break
  end
end

ii = 0
CSV.foreach(csv_file_path, headers: headers) do |row|
  ii += 1
  next unless ii > 6

  amt = (row['FY22 Actual '].gsub(/,/, "").to_i / 1000000.0).round(2)

  fund = row['Fund']
  cat = row['Category of Government']
  dest_dept = row['Department']
  dest_class = row['Class']

  # fund -> cat
  if row['Record Type'] == "Expense"
    puts "#{fund} [#{amt}] #{cat}"
  end
  
  # cat -> dest_dept
  if row['Record Type'] == "Expense"
    puts "#{cat} [#{amt}] #{dest_dept}"
  end

  # cat -> dest_dept
  if row['Record Type'] == "Expense"
    puts "#{dest_dept} [#{amt}] #{dest_class}"
  end

  
end
