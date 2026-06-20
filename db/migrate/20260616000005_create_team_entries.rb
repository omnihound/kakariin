class CreateTeamEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :team_entries do |t|
      t.references :division, null: false, foreign_key: true

      t.string  :name,   null: false  # team display name
      t.integer :seed                 # null until seeded
      # "pending" | "confirmed" | "withdrawn"
      t.string  :status, null: false, default: "pending"

      t.timestamps
    end

    add_index :team_entries, [ :division_id, :name ], unique: true
  end
end
