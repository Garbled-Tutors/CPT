class CreateDicts < ActiveRecord::Migration
  def up
    execute("CREATE SCHEMA dict")
    #create_table :dict do |t|

      #t.timestamps
    #end
  end

  def down
    execute("DELETE SCHEMA dict")
    #drop_table 'dict'
  end
end
