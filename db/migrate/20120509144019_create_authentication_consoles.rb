class CreateAuthenticationConsoles < ActiveRecord::Migration
  def self.up
    create_table :authentication_consoles do |t|
      t.text :host
      t.text :port
      t.text :name
      t.text :description
      t.timestamps
    end
  end

  def self.down
    drop_table :authentication_consoles
  end
end
