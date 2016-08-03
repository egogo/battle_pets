Sequel.migration do
  change do
    create_table :pets do
      primary_key :id
      String :name, null: false

      Integer :strength, default: 0
      Integer :agility, default: 0
      Integer :wit, default: 0
      Integer :senses, default: 0

      Integer :experience, default: 0
    end
  end
end
