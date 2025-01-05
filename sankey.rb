#!/usr/bin/env ruby

# usage:
#    ./sankey.rb > sankey_data.txt
#

require 'csv'

# Example of parsing a CSV file
$csv_file_path = './Governor-FY24_25-Recommended-Budget.csv'

header_row_number = 5
$headers = []

rows = CSV.read($csv_file_path)

rows.each_with_index do |row, ii|
  if ii == header_row_number
    $headers = row
    break
  end
end

$flows = Hash.new{ |hash, key| hash[key] = Hash.new(0) }

def add_flow(source, dest, amt)
  $flows[source][dest] += amt
end

def populate_flow_data
  ii = 0
  CSV.foreach( $csv_file_path , headers: $headers) do |row|
    ii += 1
    next unless ii > 6

    amt = row['FY22 Actual '].to_i
    fund = row['Fund']
    cat = row['Category of Government']
    dept = row['Department']
    agency = row['Agency']
    activity = row['Activity']
    dest_class = row['Class']
    
    if row['Record Type'] == "Expense"
      add_flow(fund, cat, amt)
      add_flow(cat, dept, amt)
      add_flow(dept, agency, amt)
      #add_flow(agency, activity, amt)
      add_flow(agency, dest_class, amt)
    end
    
  end

end

def output_flow_data
  $flows.each_pair do |src, details|
    details.each_pair do |dest, amt|
      puts " #{src} [#{amt}] #{dest} "
    end
  end
end

def calculate_class_percents

  departments = Hash.new{ |hash, key| hash[key] = Hash.new(0) }

  $flows.each_pair do |src, details|
    details.each_pair do |dest, amt|
      if dest == "018-Overtime"
        departments[src][:overtime] = amt
      elsif dest == "080-Out-Of State Travel"
        departments[src][:travel] = amt
      end      
    end
  end


  $flows.each_pair do |src, details|
    details.each_pair do |dest, amt|
      if departments.keys.include?(dest)
        departments[dest][:total] += amt
      end      
    end
  end
  
  puts "travel"
  departments.map { |k, v| [k, v] }.reject { |k,v| v[:total] == 0 || v[:travel] == 0 }.sort_by { |k,v| v[:travel].to_f / v[:total] }.reverse.each do | k, v|
    puts "#{ sprintf("%4.1f", ((v[:travel].to_f / v[:total]) * 100).round(1)) }% - #{k} - #{v[:travel]}"
  end

  puts "overtime"
  departments.map { |k, v| [k, v] }.reject { |k,v| v[:total] == 0 || v[:overtime] == 0 }.sort_by { |k,v| v[:overtime].to_f / v[:total] }.reverse.each do | k, v|
    puts "#{ sprintf("%4.1f", ((v[:overtime].to_f / v[:total]) * 100).round(1)) }% - #{k}"
  end

  puts "combined"
  departments.map { |k, v| [k, v] }.reject { |k,v| v[:total] == 0 || v[:overtime] == 0 }.sort_by { |k,v| (v[:overtime].to_f + v[:travel].to_f) / v[:total] }.reverse.each do | k, v|
    puts "#{ sprintf("%4.1f", (((v[:overtime].to_f + v[:travel].to_f) / v[:total]) * 100).round(1)) }% - #{k}"
  end


  
end


## top-level functions

def write_sankey_file
  populate_flow_data
  write_sankey_file
  
  file = File.open("./sankey_display_settings.txt", "r")
  contents = file.read
  puts contents
end

def percents
  puts "percents"
  populate_flow_data
  calculate_class_percents

end

write_sankey_file
