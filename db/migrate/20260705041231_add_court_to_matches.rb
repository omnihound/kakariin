class AddCourtToMatches < ActiveRecord::Migration[8.1]
  def change
    add_reference :matches, :court, foreign_key: true
    remove_column :matches, :mat_number, :integer
  end
end
