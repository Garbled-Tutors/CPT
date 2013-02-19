require 'active_record'
require 'csv'

class MedappDbActions
  def self.update_patient_class
    con = ActiveRecord::Base.connection()
    con.execute "ALTER TABLE visits DISABLE TRIGGER ALL;"
    con.execute "update visits set patient_class = 'IN' where patient_class = 'I'"
    con.execute "update visits set patient_class = 'OUT' where patient_class = 'O'"
    con.execute "update visits set patient_class = 'ED' where patient_class = 'E'"
    con.execute "ALTER TABLE visits ENABLE TRIGGER ALL;"
  end

  def self.update_patient_class_back
    con = ActiveRecord::Base.connection()
    con.execute "ALTER TABLE visits DISABLE TRIGGER ALL;"
    con.execute "update visits set patient_class = 'I' where patient_class = 'IN'"
    con.execute "update visits set patient_class = 'O' where patient_class = 'OUT'"
    con.execute "update visits set patient_class = 'E' where patient_class = 'ED'"
    con.execute "ALTER TABLE visits ENABLE TRIGGER ALL;"
  end

  def self.process_csv_dictionary name, hospital_specific
    hosp_path = hospital_specific ? File.join("hospitals", HOSPITAL) : ""
    dict_path = File.join(Rails.root.to_s, hosp_path, 'db', "dict", "#{name}.csv")

    columns = nil

    unless File.exists? dict_path 
      raise "Warning: dictionary #{dict_path} not found, import skipped."
    end

    CSV.foreach(dict_path) do |row|
      if columns.nil?
        columns = row
        next
      end

      data = Hash[columns.zip(row)]

      yield data if block_given?

    end
  end

  def self.load_dictionary name, model, schema, hospital_specific, key_field=""
    process_csv_dictionary name, hospital_specific do |data|
      updated = false

      adt_create_data = Hash.new
      adt_update_data = Hash.new

      yield data, adt_create_data, adt_update_data if block_given?

      # if key field supplied and it's value not nil in CSV, search by it. Update if found and insert if not
      if key_field && data[key_field]
        rec = model.find :first, :conditions=>{ key_field=>data[key_field] }
        if rec
          model.update rec.id, data.merge(adt_update_data).reject { |k,v| k == key_field }
          updated = true
        end
        # else try to search by all other fields. Skip if found and insert if not
      else
        updated = (model.count(:conditions=>data) > 0)
      end

      # if record not found, and we didn't decide to skip it, then insert
      #model.create!(data.merge(adt_create_data).reject { |k,v| v.nil? }) unless updated
      unless updated
        obj = model.new data.merge(adt_create_data).reject { |k,v| v.nil? }
        obj.id = data['id'] if data['id']
        obj.save! #false
      end
    end
  end
end
