class CreateCompanies < ActiveRecord::Migration[6.0]
  def change
    create_table :companies do |t|
      t.string :name
      t.text :address
      t.string :tel
      t.timestamps
    end
  end
end
