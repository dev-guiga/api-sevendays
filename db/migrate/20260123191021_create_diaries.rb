class CreateDiaries < ActiveRecord::Migration[8.1]
  def change
    create_table :diaries do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description, null: false
      t.timestamps
    end
    add_index :diaries, :user_id, unique: true
  end
end
