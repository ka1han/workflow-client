#-----------------------------------------------------------------------------------------------------------------------
# == Synopsis
# Controller used to handle staged tickets.
#
# == Author
# Christopher Lee christopher_lee@rapid7.com
#-----------------------------------------------------------------------------------------------------------------------
class StagedTicketsController < ApplicationController
  respond_to :html

  #---------------------------------------------------------------------------------------------------------------------
  # Loads the ticket data for the different scopes.
  #---------------------------------------------------------------------------------------------------------------------
  def index
    @tickets = []
    staged_tickets = TicketsToBeProcessed.find_all_by_staged(true)
    staged_tickets.each do |staged_ticket|
      data = {}
      ticket_data = staged_ticket.ticket_data

      data[:id] = staged_ticket[:id]
      case ticket_data[:scope_id]
        when 1
          data[:single_device] = true
          data[:single_vuln] =true
          data[:device_string] = ticket_data[:name]
          data[:vuln_string] = VulnInfo.get_vuln_title(ticket_data[:vuln_id])
        when 2
          data[:device_string] = build_option_string([ticket_data[:name]])
          vulns = []
          vuln_data = data[:host_vulns]
          vuln_data.each do |vuln_id, vuln_info|
            vulns << VulnInfo.get_vuln_title(vuln_id)
          end
          data[:vuln_string] = build_option_string(vulns)
        when 3
          data[:vuln_string] = build_option_string([VulnInfo.get_vuln_title(ticket_data[:ticket_id])])
          hosts = []
          ticket_data[:hosts].each do |host|
            hosts << host[:name]
          end
          data[:device_string] = build_option_string(hosts)
        else
          # TODO: Maybe log.
          next
      end

      @tickets << data
    end

    @tickets
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Unsets the staged flag for the passed in IDs.
  #---------------------------------------------------------------------------------------------------------------------
  def update
    unstaged_tickets = TicketsToBeProcessed.find(params[:ticket_ids])
    unstaged_tickets.each do |ticket|
      ticket.staged = false
      ticket.save
    end

    redirect_to '/staged_tickets'
  end

  private

  #---------------------------------------------------------------------------------------------------------------------
  # Aggregates option data in option tags for use in the view.
  #---------------------------------------------------------------------------------------------------------------------
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