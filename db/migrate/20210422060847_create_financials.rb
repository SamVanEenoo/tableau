class CreateFinancials < ActiveRecord::Migration[6.0]
  def change
    create_table :financials do |t|
      t.string :key
      t.decimal :value

      t.timestamps
    end
  end
end
