class CreateUserData < ActiveRecord::Migration
  def change
    create_table :user_data do |t|
      t.string :username
      t.string :password
      t.integer :count

      t.timestamps
    end
  end
end
