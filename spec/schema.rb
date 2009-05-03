ActiveRecord::Schema.define(:version => 0) do
  create_table :legacy_things, :force => true do |t|
    t.string  :legacy_name
    t.string  :legacy_description
  end
  
  create_table :things, :force => true do |t|
    t.string  :name
    t.string  :description
    t.integer :legacy_id
    t.string  :legacy_class
  end
end