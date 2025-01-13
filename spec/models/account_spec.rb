require 'rails_helper'

RSpec.describe Account, type: :model do
  describe 'when it has a downstream transfer' do
    let!(:budget) { create(:budget, name: '1996 budget' ) }
    let!(:account1) { create(:account, name: '01 - General Fund', budget:) }
    let!(:account2) { create(:account, name: '02 - Gold Depository', budget:) }
    let!(:transfer12) { create(:transfer, source: account1, dest: account2, budget: ) }

    let!(:account3) { create(:account, name: '03 - Handcart', budget:) }
    let!(:transfer23) { create(:transfer, source: account2, dest: account3, budget: ) }

    let!(:account4) { create(:account, name: '04 - Wheels', budget:) }
    let!(:transfer34) { create(:transfer, source: account3, dest: account4, budget: ) }

    let!(:account_left) { create(:account, name: 'left', budget:) }
    let!(:account_right) { create(:account, name: 'right', budget:) }
    let!(:account_bottom) { create(:account, name: 'bottom', budget:) }

    let!(:transfer_lb) { create(:transfer, source: account_left, dest: account_bottom, budget: ) }
    let!(:transfer_rb) { create(:transfer, source: account_right, dest: account_bottom, budget: ) }
    
    
    it 'relations work' do
      expect(account1.transfers_in).to eq([])
      expect(account1.transfers_out).to eq([transfer12])

      expect(account2.transfers_in).to eq([transfer12])
      expect(account2.transfers_out).to eq([transfer23])
    end

    it 'indirect relations work' do
      expect(account1.upstream_direct).to eq([])
      expect(account1.downstream_direct).to eq([account2])

      expect(account2.upstream_direct).to eq([account1])
      expect(account2.downstream_direct).to eq([account3])

      expect(account3.upstream_direct).to eq([account2])
      expect(account3.downstream_direct).to eq([account4])

      expect(account4.upstream_direct).to eq([account3])
      expect(account4.downstream_direct).to eq([])
    end

    it 'all_upstream_transfers() work' do
      expect(account1.all_upstream_transfers).to eq([])
      expect(account2.all_upstream_transfers).to eq([transfer12])
      expect(account3.all_upstream_transfers.to_set).to eq([transfer12, transfer23].to_set)
      expect(account4.all_upstream_transfers.to_set).to eq([transfer12, transfer23, transfer34].to_set)


      expect(account_left.all_upstream_transfers).to eq([])
      expect(account_right.all_upstream_transfers).to eq([])
      expect(account_bottom.all_upstream_transfers.to_set).to eq([transfer_lb, transfer_rb].to_set)

    end
    
    
  end
end
