class CreateTournamentRegistrations < ActiveRecord::Migration[8.1]
  def change
    create_table :tournament_registrations do |t|
      t.references :competitor, null: false, foreign_key: true
      t.references :division,   null: false, foreign_key: true

      t.integer :seed    # organiser-assigned seeding; null until seeded
      # "pending" | "confirmed" | "withdrawn"
      t.string  :status, null: false, default: "pending"

      t.timestamps
    end

    add_index :tournament_registrations, [ :competitor_id, :division_id ], unique: true, name: "index_registrations_on_competitor_and_division"
  end
end
