class Budget < ApplicationRecord
  belongs_to :timeperiod
  has_many :accounts
#  def self.new(name_str, period_str)
#    timeperiod = Timeperiod.find_or_create_by(name: config[:period])
#    Budget.find_or_create_by(name: config[:name], timeperiod: )
#  end

  
  def add_flow(source, dest, amount)
    source = Cat.find_or_create_by(name: source, budget: self )
    dest = Cat.find_or_create_by(name: dest, budget: self)
    Transfer.find_or_create_by(source: , dest:, budget: self , amount: )
  end


end
