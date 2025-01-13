class Account < ApplicationRecord
  belongs_to :budget

  has_many :transfers_out, class_name: "Transfer", foreign_key: "source_id"
  has_many :transfers_in, class_name: "Transfer", foreign_key: "dest_id"

  has_many :downstream_direct, class_name: "Account", through: :transfers_out, :source => "dest"

  has_many :upstream_direct, class_name: "Account", through: :transfers_in, :source => "source"

  def all_upstream_transfers(known_transfers = [])
    new_transfers = transfers_in.to_a - known_transfers
    # puts "1: new_transfers = #{new_transfers}"
    new_transfers.map(&:source).each do |source|
      # puts "   recurse >>"
      indirect = source.all_upstream_transfers(known_transfers)
      # puts "   <<< recurse "
      # puts "2: indirect = #{indirect}"
      new_transfers += indirect
    end
    # puts "3: about to return #{new_transfers}"
    new_transfers
  end
  
end
