class CreateRepositories < ActiveRecord::Migration[6.1]
  def change
    create_table :repositories do |t|
      t.integer :github_id, unique: true
      t.string :name
      t.string :full_name
      t.string :language
      t.string :clone_url
      t.integer :issues_count
      t.string :aasm_state
      t.boolean :last_check_passed, default: false
      t.datetime :repo_created_at
      t.datetime :repo_updated_at

      t.timestamps
    end
  end
end
