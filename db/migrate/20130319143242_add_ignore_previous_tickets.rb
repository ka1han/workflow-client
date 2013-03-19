class AddIgnorePreviousTickets < ActiveRecord::Migration
  def self.up
    add_column :ticket_configs, :ignore_previous_tickets, :boolean
  end

  def self.down
  end
end
