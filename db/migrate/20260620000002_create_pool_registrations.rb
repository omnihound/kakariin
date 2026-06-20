class CreatePoolRegistrations < ActiveRecord::Migration[8.1]
  def change
    create_table :pool_registrations do |t|
      t.references :pool,       null: false, foreign_key: true
      t.references :competitor, null: false, foreign_key: true

      t.integer :seed  # within-pool seed; null until seeded

      t.timestamps
    end

    add_index :pool_registrations, [ :pool_id, :competitor_id ], unique: true
  end
end