class Add < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :firm_id, :integer
    add_column :users, :firm_name, :string
  end
end
