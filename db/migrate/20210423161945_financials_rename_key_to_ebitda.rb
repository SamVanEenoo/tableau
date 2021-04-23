class FinancialsRenameKeyToEbitda < ActiveRecord::Migration[6.0]
  def change
    rename_column :financials, :value, :ebitda
    remove_column :financials, :key
  end
end
