class AddEbitToFinancials < ActiveRecord::Migration[6.0]
  def change
    add_column :financials, :ebit, :decimal
  end
end
