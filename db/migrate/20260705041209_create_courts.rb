class CreateCourts < ActiveRecord::Migration[8.1]
  def change
    create_table :courts do |t|
      t.references :tournament, null: false, foreign_key: true
      t.string :name, null: false

      t.timestamps
    end

    add_index :courts, [ :tournament_id, :name ], unique: true
  end
end
