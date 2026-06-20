class CreateCompetitors < ActiveRecord::Migration[8.1]
  def change
    create_table :competitors do |t|
      t.references :user, null: true, foreign_key: true, index: { unique: true }

      t.string  :first_name, null: false
      t.string  :last_name,  null: false
      t.string  :gender                   # "male", "female", "other"; nullable for organiser pre-registration
      t.date    :date_of_birth
      t.integer :grade_rank               # 1–6 for kyu, 1–8 for dan; null = ungraded
      t.string  :grade_type               # "kyu" or "dan"; null = ungraded
      t.string  :country, null: false, default: "AU"

      t.timestamps
    end

    add_index :competitors, [ :last_name, :first_name ]
  end
end
