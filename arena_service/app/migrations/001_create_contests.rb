Sequel.migration do
  change do
    create_table :contests do
      primary_key :id

      DateTime :started_at
      DateTime :finished_at

      String :type

      String :title, null: false

      Integer :first_pet_id
      Integer :second_pet_id

      Integer :winner_id
    end
  end
end
