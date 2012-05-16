class TicketsToBeProcessed < ActiveRecord::Base
	#serialize :ticket_data, Hash

  #---------------------------------------------------------------------------------------------------------------------
  # Used to determine if there are currently any staged tickets.
  #---------------------------------------------------------------------------------------------------------------------
  def TicketsToBeProcessed.has_staged_tickets?
    return TicketsToBeProcessed.where(:staged => true).exists?
  end
end
