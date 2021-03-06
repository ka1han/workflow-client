class CreateTicketsToBeProcessed < ActiveRecord::Migration
  def self.up
    create_table :tickets_to_be_processeds do |t|
      t.text    :ticket_id
      t.text    :ticket_data, :null => false
      t.boolean :pending_requeue, :null => false, :default => false
      t.boolean :staged, :null => false, :default => false
      t.integer :failed_attempt_count, :null => false, :default => 0
      t.text  :failed_message
    end
  end

  def self.down
    drop_table :tickets_to_be_processeds
  end
end
