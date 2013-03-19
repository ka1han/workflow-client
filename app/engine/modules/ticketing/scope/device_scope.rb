#The device scope creates one ticket per device, with all the vulns an asset has
class DeviceScope

  def self.build_ticket_data(nexpose_host, site_device_listing, hosts_data_array, ticket_config)

    #this is what we return
    res = []

    #Do we support updating tickets or closed loop ticketing
    supports_updates = ticket_config.supports_updates

    non_vulns = {}
    vuln_tickets = []

    rule_manager = RuleManager.new(ticket_config.ticket_rule)

    c = Object.const_get(ticket_config.ticket_client_type)
    ticket_client_info = TicketClients.find_by_client(c.client_name)
    client_connector = ticket_client_info.client_connector

    formatter = ticket_client_info.formatter 

    hosts_data_array.each do |host_data|
      next if host_data['vulns'].length == 0

      ip = host_data['addr']
      names = host_data['names']

      #the nexpose device id, an integer
      device_id = self.get_device_id(ip, site_device_listing)

      #hostname of the device, if one exists
      name = ''
      name = names[0] if (!names.nil? && !names.empty?)

      #os fingerprint
      fingerprint = ''
      fingerprint << (host_data['os_vendor'] || '')
      fingerprint << ' '
      fingerprint << (host_data['os_family'] || '')

      ticket_data = {
        :ip => ip,
        :nexpose_host => nexpose_host,
        :device_id => device_id,
        :name => name,
        :fingerprint => fingerprint,
        :host_vulns => host_data['vulns'],
        :formatter => formatter,
        :client_connector => client_connector,
        :ticket_op => :CREATE,
        :module_name => ticket_config.module_name
      }

      ticket_id = self.get_ticket_key(ticket_data)
      ticket_data[:ticket_id] = ticket_id

      if ticket_config.ignore_previous_tickets
        if rule_manager.passes_rules?(ticket_data)
          res << ticket_data
        end
      elsif !self.ticket_created_or_to_be_processed?(ticket_data)
        #we need to ensure the ticket passes all our rules
        if rule_manager.passes_rules?(ticket_data)
          res << ticket_data
        end
      else
        #nothing so far
      end
    end
    res
  end

  def self.get_device_id(ip, site_device_listing)
    site_device_listing.each do |device_info|
      return device_info[:device_id] if device_info[:address] =~ /#{ip}/
    end
  end

  def self.ticket_created_or_to_be_processed?(ticket_data)
    ticket_id = ticket_data[:ticket_id]
    return (TicketsCreated.where(:ticket_id => ticket_id).exists? or TicketsToBeProcessed.where(:ticket_id => ticket_id).exists?)
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Returns the ticket key for this scope type
  #---------------------------------------------------------------------------------------------------------------------
  def self.get_ticket_key(ticket)
    key = ''
    key << ticket[:module_name]
    key << '|'
    key << ticket[:nexpose_host]
    key << '|'
    key << ticket[:device_id].to_s

    key
  end
end
