class CreateRepositoryChecks < ActiveRecord::Migration[6.1]
  def change
    create_table :repository_checks do |t|
      t.boolean :passed, default: false
      t.string :issues_count
      t.string :output
      t.string :commit
      t.string :aasm_state

      t.timestamps
    end
  end
end
