class AddPoolToMatches < ActiveRecord::Migration[8.1]
  def change
    # Pool-stage matches have pool_id set; playoff matches leave it null.
    add_reference :matches, :pool, null: true, foreign_key: true
  end
end