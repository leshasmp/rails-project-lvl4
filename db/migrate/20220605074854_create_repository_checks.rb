class CreateRepositoryChecks < ActiveRecord::Migration[6.1]
  def change
    create_table :repository_checks do |t|
      t.string :name
      t.string :status
      t.boolean :passed
      t.string :issues_count
      t.string :value
      t.string :commit
      t.string :aasm_state

      t.timestamps
    end
  end
end
