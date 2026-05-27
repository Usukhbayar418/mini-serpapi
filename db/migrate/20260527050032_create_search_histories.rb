class CreateSearchHistories < ActiveRecord::Migration[8.1]
  def change
    create_table :search_histories do |t|
      t.string :query
      t.string :engine
      t.string :api_key
      t.integer :results_count
      t.integer :duration_ms
      t.string :ip
      t.string :user_agent

      t.timestamps
    end
  end
end
