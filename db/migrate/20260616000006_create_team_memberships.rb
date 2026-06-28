class CreateTeamMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :team_memberships do |t|
      t.references :team_entry, null: false, foreign_key: true
      t.references :competitor, null: false, foreign_key: true

      t.timestamps
    end

    # A competitor can only appear once per team entry
    add_index :team_memberships, [ :team_entry_id, :competitor_id ], unique: true, name: "index_team_memberships_on_entry_and_competitor"
  end
end
