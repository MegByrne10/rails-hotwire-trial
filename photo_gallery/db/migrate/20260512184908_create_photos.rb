class CreatePhotos < ActiveRecord::Migration[8.0]
  def change
    create_table :photos do |t|
      t.string :photographer_name
      t.string :source_md_url
      t.string :source_url
      t.string :alt
      t.integer :likes_count, default: 0

      t.timestamps
    end
  end
end
