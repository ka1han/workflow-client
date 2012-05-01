class StagedTickets < ApplicationController

  def index
    @tickets = []
    staged_tickets = TicketsToBeProcessed.find_all_by_staged(true)
    staged_tickets.each do |staged_ticket|
      data = {}
      ticket_data = staged_ticket.ticket_data
      data[:module_name] = ticket_data[:module_name]
      data[:device_option_string] = build_option_string(ticket_data[:vuln_data])
      data[:vuln_option_string] = build_option_string(ticket_data[:device_data])
      @tickets << data
    end
  end

  def update

  end

  private
  def build_option_string(options)
    value = ''
    options.each do |option|
      value << '<option>'
      value << option
      value << '</option>'
    end

    value
  end
end