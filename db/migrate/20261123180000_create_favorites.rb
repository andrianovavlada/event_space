class CreateFavorites < ActiveRecord::Migration[8.1]
  def change
    create_table :favorites do |t|
      t.references :user, null: false, foreign_key: true, index: false
      t.references :venue, null: false, foreign_key: true
      t.timestamps
      t.index [ :user_id, :venue_id ], unique: true
    end
  end
end
