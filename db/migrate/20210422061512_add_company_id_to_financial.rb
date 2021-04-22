class AddCompanyIdToFinancial < ActiveRecord::Migration[6.0]
  def change
    add_column :financials, :company_id, :integer
  end
end
