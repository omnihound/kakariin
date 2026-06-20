class CreateDivisions < ActiveRecord::Migration[8.1]
  def change
    create_table :divisions do |t|
      t.references :tournament, null: false, foreign_key: true

      t.string  :name,             null: false  # e.g. "Open Individual", "Women's Team"
      # "individual" | "team"
      t.string  :competition_type, null: false
      # "single_elimination" | "round_robin"
      t.string  :format,           null: false, default: "single_elimination"
      # "pending" | "in_progress" | "completed"
      t.string  :status,           null: false, default: "pending"

      t.timestamps
    end

    add_index :divisions, [ :tournament_id, :name ], unique: true
  end
end
