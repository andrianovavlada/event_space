class AddVenueCatalogDetails < ActiveRecord::Migration[8.1]
  def change
    create_table :cities do |t|
      t.string :name, null: false
      t.timestamps
    end
    add_index :cities, :name, unique: true

    change_table :venues do |t|
      t.references :city, foreign_key: true
      t.text :description
      t.decimal :hourly_rate, precision: 10, scale: 2
      t.boolean :availability_configured, default: false, null: false
    end
    add_check_constraint :venues, "hourly_rate >= 0", name: "venues_hourly_rate_nonnegative"

    create_table :availability_blocks do |t|
      t.references :venue, null: false, foreign_key: true
      t.date :starts_on, null: false
      t.date :ends_on, null: false
      t.timestamps
    end
    add_check_constraint :availability_blocks, "ends_on >= starts_on", name: "availability_blocks_date_order"

    create_table :reviews do |t|
      t.references :venue, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :rating, null: false
      t.text :body, null: false
      t.timestamps
    end
    add_check_constraint :reviews, "rating BETWEEN 1 AND 5", name: "reviews_rating_range"
  end
end
