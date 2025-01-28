require Rails.root.join('config', 'environment')
# require 'timeperiod'

class Importer

  $flows = Hash.new{ |hash, key| hash[key] = Hash.new }
  $spending_classes = Set.new

  $accounts = Hash.new { |hash, key| hash[key] = Array.new } # RIGHT !
  def add_account(account_name, tier_name)
    $accounts[tier_name] += [account_name]
  end
  
  def add_flow(source, dest, csv_file_path, row, amt)
    $flows[source][dest]        = Hash.new if $flows[source][dest].nil?
    $flows[source][dest][:file] = csv_file_path if $flows[source][dest][:file].nil?
    $flows[source][dest][:row]  = row if $flows[source][dest][:row].nil?
    if $flows[source][dest][:amount] then
      $flows[source][dest][:amount]  += amt
    else
      $flows[source][dest][:amount]  = amt
    end
  end


  # import a CSV file, populate TimePeriod, Budget, Flow, Account
  def import(config)

    #==================================================
    # read the headers, so we can mape "Sub-org" to "rol C", or whatever
    #
    rows = CSV.read(config[:input_file])
    headers = []
    rows.each_with_index do |row, ii|
      if ii == config[:header_row]
        headers = row
        break
      end
    end

    
    #==================================================
    # read CSV into $flows

    data_row_num        = config[:data_row ]

    header_levels          = config[:header_levels]
    header_expense_or_fund = config[:header_expense_or_fund]
    header_dollar          = config[:header_dollars]

    
    ii = 0
    CSV.foreach( config[:input_file] , headers: headers) do |row|

      ii += 1
      next unless ii > data_row_num

      level_0 = row[header_levels[0]]
      level_1 = row[header_levels[1]]
      level_2 = row[header_levels[2]]
      level_3 = row[header_levels[3]]
      level_4 = row[header_levels[4]]
      level_5 = row[header_levels[5]]
      amt = row[header_dollar].to_i
      expense_or_fund= row[header_expense_or_fund]

      # puts "level_0 = #{level_0}"
      # puts "level_1 = #{level_1}"
      # puts "level_2 = #{level_2}"
      # puts "level_3 = #{level_3}"
      # puts "level_4 = #{level_4}"
      # puts "level_5 = #{level_5}"
      # puts "amt = #{amt}"

      if "Expense" == expense_or_fund

        $spending_classes.add(level_5)
        
        add_flow(level_0, level_1, config[:input_file], ii, amt)
        add_flow(level_1, level_2, config[:input_file], ii, amt)
        add_flow(level_2, level_3, config[:input_file], ii, amt)
        add_flow(level_3, level_4, config[:input_file], ii, amt)
        add_flow(level_4, level_5, config[:input_file], ii, amt)

        add_account(level_0, header_levels[0])
        add_account(level_1, header_levels[1])
        add_account(level_2, header_levels[2])
        add_account(level_3, header_levels[3])
        add_account(level_4, header_levels[4])
        add_account(level_5, header_levels[5])
        
      elsif "Funding" == expense_or_fund
      # puts " funding"
      elsif row['Record Type'] == "Position"
      # puts " position"
      else
        # ignoring col
      end

    end

    #==================================================
    # persist $flows into database
    
    timeperiod = Timeperiod.find_or_create_by(name: config[:period])
    budget = Budget.find_or_create_by(name: config[:name], timeperiod: )
    # puts " xxx = #{$flows.keys.uniq}"

    accts_h = {}
    $accounts.each do |tier_name, account_names|
      account_tier = AccountTier.find_or_create_by(budget: budget, name: tier_name)
      account_names.each do |name|
        if accts_h[name].nil?
          accts_h[name] = Account.find_or_create_by(name:, account_tier: )
        end
      end
    end
    
    # acct_names = ($flows.keys + $flows.values.map(&:keys)).flatten.uniq
    # # puts "acct_names = #{acct_names}"
    # accts_h = {}
    # acct_names.each do  |name|
    #   # puts "create acct #{name}"
    #   accts_h[name] = Account.find_or_create_by(name:, budget: )
    # end

    ### XXXX this is wrong because we don't sum up all of the flows, e.g

    count = 0
    $flows.each_pair do |source_name, outflow_hash|
      outflow_hash.each_pair do |dest_name, details_hash|
        source = accts_h[source_name]
        dest = accts_h[dest_name]
        amount = details_hash[:amount]
        file = details_hash[:file]
        row = details_hash[:row]
        before_count = Transfer.count
        transfer = Transfer.find_or_create_by(budget: , source: , dest: , amount: , file:, row: )
        count += 1 if Transfer.count > before_count
      end
    end
    puts "Transfers created: #{count} "
  end

  # def print_dept_percents
  #   departments_scaled = Hash.new

  #   departments_scaled.each_pair do |dept, hh|
  #     puts "---- #{dept}"
  #     hh.to_a.sort_by { |pair| pair[1]}.reverse[0,10].each do |pair|
  #       puts "  * #{sprintf("%5.1f", pair[1] * 100)}% #{pair[0]}"
  #     end
  #     puts "\n"
  #   end  

  #   departments_scaled.each_pair do |dept, hh|
  #     filename_base = "/tmp/" + dept.gsub(/[ &:']/, "-").gsub(/-+/, "-").downcase

  #     filename_pie = filename_base + ".pie"
  #     file = File.open(filename_pie, "w")
  #     hh.to_a.sort_by { |pair| pair[1]}.reverse[0,10].each do |pair|
  #       file.write("#{sprintf("%5.1f", pair[1] * 100)},#{pair[0].gsub(/&/, "and")}\n")
  #     end
  #     file.close

  #     filename_svg = filename_base + ".svg"
  #     filename_annotated = filename_base + ".png"
      
  #     pie_cmd = "piechart  --percent  --order value,legend --color contrast #{filename_pie} > #{filename_svg}"
  #     # puts "pie_cmd = #{pie_cmd}"
  #     `#{pie_cmd}`
  #     convert_cmd = "convert #{filename_svg} -gravity north -extent 900x700 -pointsize 50 -fill black  -annotate +0+600 \"#{dept.downcase}\"  #{filename_annotated}"
  #     `#{convert_cmd}`
  #     puts "create pie chart #{filename_annotated}"

  #   end  

    
  # end

  # returns a hash
  #   keys: accounts in specified tier
  #   values: a hash mapping dest-accounts to number 0.0 - 1.0 showing scaled output from source account
  #
  # E.g.
  #  { <Acct1 name: "EXO020010-EXECUTIVE OFFICE"> => {  "011-Personal Services-Unclassified"=>0.6,
  #                                                      "016-Personal Services Non Classifi"=>0.1,
  #                                                      "020-Current Expenses"=>0.1 ... },
  #    <Acct2 name: "OIT030010-INFORMATION TECHNOLOGY"> => {  "011-Personal Services-Unclassified"=>0.01,  ... },
  #     ...
  #   }
  def scale(acct_tier)

    at = AccountTier.find_by_name(acct_tier)
    raise "no such account tier" unless at

    transfers_out_scaled = Hash.new{ |hash, key| hash[key] = Hash.new(0) }
    at.accounts.each do |acct|
      total = acct.transfers_out.includes(:dest).map(&:amount).sum
      transfers_out_scaled[acct] = acct.transfers_out.map { |transfer| [transfer.dest.name, transfer.amount.to_f / total ] }.to_h
    end
    transfers_out_scaled
  end
  
  # Look at data from the spending-class perspective (e.g. IT, overtime, out-of-state travel, etc.)
  # For each spending category, report on which departments
  #
  def find_outliers(acct_tier)
    at = AccountTier.find_by_name(acct_tier)
    raise "no such account tier" unless at

    transfers_out_scaled = scale(acct_tier)
    
    # create a mapping of output-accts -> [ scaled amount, scaled amount, scaled amount ... ]
    # e.g.   
    #  {  "011-Personal Services-Unclassified"=>[ 0.6, 0.1, 0.1 ...],
    #      "016-Personal Services Non Classifi"=> [ 0.2, 0.2 .. ],  }
    # 
    transfers_out_scaled_grouped = Hash.new{ |hash, key| hash[key] = Array.new }
    transfers_out_scaled.each { |src, hh| hh.each_pair { |dest, fraction| transfers_out_scaled_grouped[dest] += [fraction] }}
    transfers_out_stats = transfers_out_scaled_grouped.map do |dest, arr| 
      avg = arr.sum / arr.length
      variance_array = arr.map{|fract| (fract - avg) }
      std_dev = variance_array.size == 0 ? 0 :   Math.sqrt(variance_array.sum { |v| v ** 2} / variance_array.size)
      [ dest, { avg:, std_dev: } ]
    end.to_h

    transfers_out_scaled.each do |src, hh|
      avg = transfers_out_stats[:avg]
      std_dev = transfers_out_stats[:std_dev]
      puts "--- #{src.name} avg = #{sprintf("%3.2f", (avg || 0) * 100)}%, std_dev = #{sprintf("%2.2f", (std_dev || 0) * 100)}"
#      arr[0,10].each do |pair|
#        devs = (pair[1] - avg) / std_dev
#        puts "  * #{sprintf("%5.2f", pair[1] * 100) }% + #{ sprintf("%2.0f", devs) } std devs    #{pair[0] }"
    end
    
  end


  def output_sankey

    Transfer.all.includes([:source, :dest]).each do |transfer|
      puts " #{transfer.source.name} [#{transfer.amount}] #{transfer.dest.name} "
    end
    file = File.open("./sankey_display_settings.txt", "r")
    contents = file.read
    puts contents

  end

  
end
