class UpdateReservationsUniqueIndexToPartial < ActiveRecord::Migration[8.1]
  def up
    # Remove the old unique index that prevents any duplicate (user_id, book_id)
    remove_index :reservations, name: 'index_res_on_user_and_book'
    
    # Create a partial unique index that only applies to active reservations
    # This allows users to have multiple reservations for the same book
    # as long as only one is active at a time
    add_index :reservations, [:user_id, :book_id], 
              unique: true, 
              name: 'index_res_on_user_and_book_active',
              where: "status = 0" # 0 = active
  end

  def down
    # Remove the partial index
    remove_index :reservations, name: 'index_res_on_user_and_book_active'
    
    # Restore the original unique index
    add_index :reservations, [:user_id, :book_id], 
              unique: true, 
              name: 'index_res_on_user_and_book'
  end
end
