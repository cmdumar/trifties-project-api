class CreateReservations < ActiveRecord::Migration[7.0]
  def change
    create_table :reservations do |t|
      t.references :user, foreign_key: true, null: false
      t.references :book, foreign_key: true, null: false
      t.integer :status, null: false, default: 0   # 0: active, 1: cancelled, 2: completed
      t.datetime :reserved_at, null: false
      t.datetime :expires_at
      t.text :note
      t.timestamps
    end

    add_index :reservations, [:user_id, :book_id], unique: true, name: 'index_res_on_user_and_book'
  end
end
