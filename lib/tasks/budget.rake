require 'csv'
require 'yaml'


namespace :budget do
  $flows = Hash.new{ |hash, key| hash[key] = Hash.new(0) }
  $spending_classes = Set.new
  $departments_scaled = Hash.new

  # populates $flows
  def populate_flow_data

    # read config
    #
    configfile = "./.rakefile.yaml"
    if FileTest.exist?(configfile)
      config  = YAML.load_file(configfile)
      csv_file_path = config[:input_file]

    else
      raise "no config file"
    end


    def add_flow(source, dest, amt)
      $flows[source][dest] += amt
    end

    def csv_to_flow(csv_file_path, config)
      # read the header row to populate `headers[]`
      # 
      rows = CSV.read(csv_file_path)
      headers = []
      rows.each_with_index do |row, ii|
        if ii == config[:header_row]
          headers = row
          break
        end
      end
      # puts "headers = #{headers}"
      
      data_row_num        = config[:data_row ]

      header_level_1        = config[:header_level_1]
      header_level_2        = config[:header_level_2]
      header_level_3        = config[:header_level_3]
      header_level_4        = config[:header_level_4]
      header_level_5        = config[:header_level_5]
      header_level_6        = config[:header_level_6]
      
      header_expense_or_fund = config[:header_expense_or_fund]
      header_dollar         = config[:header_dollars]

      # puts "header_expense_or_fund = #{header_expense_or_fund}"
      
      ii = 0
      CSV.foreach( csv_file_path , headers: headers) do |row|

        ii += 1
        next unless ii > data_row_num

        level_1 = row[header_level_1]
        level_2 = row[header_level_2]
        level_3 = row[header_level_3]
        level_4 = row[header_level_4]
        level_5 = row[header_level_5]
        level_6 = row[header_level_6]
        amt = row[header_dollar].to_i
        expense_or_fund= row[header_expense_or_fund]

        # puts "level_1 = #{level_1}"
        # puts "level_2 = #{level_2}"
        # puts "level_3 = #{level_3}"
        # puts "level_4 = #{level_4}"
        # puts "level_5 = #{level_5}"
        # puts "level_6 = #{level_6}"
        # puts "amt = #{amt}"


        
        if "Expense" == expense_or_fund

          $spending_classes.add(level_6)
          

          add_flow(level_1, level_2, amt)
          add_flow(level_2, level_3, amt)
          add_flow(level_3, level_4, amt)
          add_flow(level_4, level_5, amt)
          add_flow(level_5, level_6, amt)

        elsif "Funding" == expense_or_fund
        # puts " funding"
        elsif row['Record Type'] == "Position"
        # puts " position"
        else
          # ignoring col
        end

      end
    end

    # puts "$spending_classes = #{$spending_classes}"
    
    csv_to_flow(csv_file_path, config)


    # puts "populate_flow_data() $spending_classes = #{$spending_classes.inspect}"
  end


  def output_flow_data
    $flows.each_pair do |src, details|
      details.each_pair do |dest, amt|
        puts " #{src} [#{amt}] #{dest} "
      end
    end
  end

  # def find_personnel_placeholders
  #   $flows.each_pair do |src, details|
  #     details.each_pair do |dest, amt|
  #       if $spending_classes.include?(dest)
  #         if amt < 1000 && amt > 0 && ["059-Temp Full Time","FTE1-Permanent Classified","FTE2-Unclassified Positions"].include?(dest)
  #          puts "#{src} / #{dest} = #{amt}"
  #         end
  #       end
  #     end
  #   end
  # end

  def scale_depts
    #puts "scale_depts() $spending_classes = #{$spending_classes.inspect}"
    
    departments = Hash.new{ |hash, key| hash[key] = Hash.new(0) }
    
    $flows.each_pair do |src, details|
      details.each_pair do |dest, amt|
        # is the flow is from an acct_class to a class (lead node)
        if $spending_classes.include?(dest)
          # dest_sym = dest.downcase.gsub(/[ -]/, '_').to_sym
          departments[src][dest] = amt
        end
      end
    end

    # puts "departments = #{departments}"

    $departments_scaled = Hash.new

    departments.each_pair do |dept, hh|

      # puts "dept = #{dept} / hh = #{hh}"
      
      total = hh.to_a.inject(0) { |sum, pair| sum + pair[1] }
      next if total == 0
      scaled_h = hh.to_a.map { |expense_name, spending_dollars| [expense_name, spending_dollars * 1.0 / total ] }.to_h

      # puts "-------------------- #{dept}"
      # puts "raw = #{hh.inspect}"
      # puts "sum percent = #{ scaled_h.map { |k,v| v }.sum }"
      # scaled_h[:total] = total
      # puts "scaled = #{scaled_h.inspect}"

      $departments_scaled[dept] = scaled_h
      
    end
  end

  # Look at data from the spending-class perspective (e.g. IT, overtime, out-of-state travel, etc.)
  # For each spending category, report on which departments
  #
  def calculate_class_percents

    $spending_classes.to_a.sort.each do |sp_class|

      arr = $departments_scaled.map { |k, hh| [ k, hh[sp_class] || 0.0 ] }.sort_by { | pair | pair[1] }.reverse
      next if arr.length == 0
      avg = arr.map { |pair| pair[1] }.sum / arr.length

      variance_array = arr.map{|pair| (pair[1] - avg) }
      std_dev = variance_array.size == 0 ? 0 :   Math.sqrt(variance_array.sum { |v| v ** 2} / variance_array.size)

      
      puts "---- #{sp_class} avg = #{sprintf("%3.2f", avg * 100)}%, std_dev = #{sprintf("%2.2f", std_dev * 100)} percentage pts "

#      if arr.reject { |k, v| v == 0.0 }.length < 3
#        puts "skipped bc too few"
#        next
#      end
      


      arr[0,10].each do |pair|
        devs = (pair[1] - avg) / std_dev
        puts "  * #{sprintf("%5.2f", pair[1] * 100) }% + #{ sprintf("%2.0f", devs) } std devs    #{pair[0] }"
      end
    end
    
  end

  def print_dept_percents

    $departments_scaled.each_pair do |dept, hh|
      puts "---- #{dept}"
      hh.to_a.sort_by { |pair| pair[1]}.reverse[0,10].each do |pair|
        puts "  * #{sprintf("%5.1f", pair[1] * 100)}% #{pair[0]}"
      end
      puts "\n"
    end  

    $departments_scaled.each_pair do |dept, hh|
      filename_base = "/tmp/" + dept.gsub(/[ &:']/, "-").gsub(/-+/, "-").downcase

      filename_pie = filename_base + ".pie"
      file = File.open(filename_pie, "w")
      hh.to_a.sort_by { |pair| pair[1]}.reverse[0,10].each do |pair|
        file.write("#{sprintf("%5.1f", pair[1] * 100)},#{pair[0].gsub(/&/, "and")}\n")
      end
      file.close

      filename_svg = filename_base + ".svg"
      filename_annotated = filename_base + ".png"
      
      pie_cmd = "piechart  --percent  --order value,legend --color contrast #{filename_pie} > #{filename_svg}"
      # puts "pie_cmd = #{pie_cmd}"
      `#{pie_cmd}`
      convert_cmd = "convert #{filename_svg} -gravity north -extent 900x700 -pointsize 50 -fill black  -annotate +0+600 \"#{dept.downcase}\"  #{filename_annotated}"
      `#{convert_cmd}`
      puts "create pie chart #{filename_annotated}"

    end  

    
  end



  ## top-level functions

  desc "generate sankey data to stdout"
  task :sankey do
    populate_flow_data
    output_flow_data
    
    file = File.open("./sankey_display_settings.txt", "r")
    contents = file.read
    puts contents
  end

  task :default => :sankey

  desc "calculate the percentages of each department"
  task :analyze do
    populate_flow_data
    scale_depts
    calculate_class_percents
  end

  task :headcount do
    find_personnel_placeholders
  end

  desc "calculate the percentages of each department"
  task :department do
    populate_flow_data
    scale_depts
    print_dept_percents
  end

end
