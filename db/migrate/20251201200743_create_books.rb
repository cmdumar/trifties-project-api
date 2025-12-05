class CreateBooks < ActiveRecord::Migration[7.0]
  def change
    create_table :books do |t|
      t.string  :title, null: false
      t.string  :author
      t.string  :isbn
      t.text    :description
      t.string  :condition, null: false, default: 'good'
      t.decimal :price, precision: 8, scale: 2, null: false, default: 0.0
      t.integer :status, null: false, default: 0
      t.references :category, foreign_key: true
      t.date    :published_at
      t.timestamps
    end

    add_index :books, :isbn
  end
end
