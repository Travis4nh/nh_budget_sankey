require 'csv'
require 'yaml'
require 'importer'

namespace :budget do
  def parse_config
    configfile = ARGV[1] || "./.rakefile.yaml"
    config = nil
    if FileTest.exist?(configfile)
      config  = YAML.load_file(configfile)
    else
      raise "no config file"
    end
    config
  end

  ## top-level functions
  task :default => :sankey

  
  desc "import a data source"
  task :clear do
    Transfer.destroy_all
    Account.destroy_all
    AccountTier.destroy_all
    Budget.destroy_all
    Timeperiod.destroy_all
  end

  desc "import a data source"
  task :report do
    puts "Transfer = #{Transfer.count}"
    puts "Account = #{Account.count}"
    puts "AccountTiers = #{AccountTier.count}"
    AccountTier.all.each do |acct|
      puts "   * #{acct.name}"
    end
    puts "Budget = #{Budget.count}"
    puts "Timeperiod = #{Timeperiod.count}"
  end

  desc "clear old data, read CSV, sankey -> stdout"
  task :quick => [:clear] do
    config = parse_config
    Importer.new.import(config)
    Importer.new.output_sankey
  end

  desc "sankey -> stdout"
  task :sankey  do
    Importer.new.output_sankey
  end

  desc "for each element in AccountTier X, calculate the percentages of its spending in the next sub-tier"
  task :scale do
    acct_tier = ARGV[1]
    raise "need to specify tier name" unless acct_tier
    Importer.new.scale(acct_tier)
  end

  desc "for each element in AccountTier X, calculate the percentages of its spending in the next sub-tier"
  task :find_outliers, [:acct_tier] do |task, args|
    raise "need to specify tier name" unless args[:acct_tier]
    Importer.new.find_outliers(args[:acct_tier])
  end

  
  
  desc "for each element in AccountTier X, calculate the percentages of its spending in the next sub-tier"
  task :analyze do
    acct_tier = ARGV[1]
    raise "need to specify tier name" unless acct_tier
    calculate_sub_percents(acct_tier)
  end

  desc "calculate the percentages of each department"
  task :department => :environment  do
    populate_flow_data
    scale_depts
    print_dept_percents
  end

  desc "import a town of Weare budget"
  task :weare => :populate_weare do
  end
  
end
