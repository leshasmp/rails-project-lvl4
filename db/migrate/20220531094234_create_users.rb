class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :nickname
      t.string :name
      t.string :email
      t.string :image_url
      t.string :token

      t.timestamps
    end
    add_index :users, :email
  end
end
