require 'medapp_db_actions'
class CreateDictCpts < ActiveRecord::Migration
  #def change
    #create_table :dict_cpts do |t|

      #t.timestamps
    #end
  #end
  def up
    create_table 'dict.cpts' do |t|
      t.string :code, :limit => 5
      t.text :long_description
      t.string :medium_description, :limit => 48
      t.string :short_description, :limit => 28 
    end
    MedappDbActions.load_dictionary "cpts", Dict::Cpt, "dict", false, "code"
  end


  def down
    drop_table 'dict.cpts'
  end
end
