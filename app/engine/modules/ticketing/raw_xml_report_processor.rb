#-----------------------------------------------------------------------------------------------------------------------
# == Synopsis
# Parses raw XML report from nexpose
#
# == Author
# Christopher Lee christopher_lee@rapid7.com
#-----------------------------------------------------------------------------------------------------------------------

class RawXMLReportProcessor

  attr_accessor :host_data

  #---------------------------------------------------------------------------------------------------------------------
  # Sets up the callback for the parser.
  #---------------------------------------------------------------------------------------------------------------------
  def initialize
    @logger = LogManager.instance
    @parser = Rex::Parser::NexposeXMLStreamParser.new

    #setting this to false tells the parser to pass us the non-vulnerable
    #checks as well, this enables closed-loop ticketing
    @parser.parse_vulnerable_states_only false

    @parser.callback = proc { |type, value|
      case type
        when :host
          @host_data << value
        when :vuln
          # Doing this allows us to flush data to the database and avoids
          # using up more memory than needed.
          add_to_vuln_db value
        else
          raise 'Invalid type when parsing raw XML report'
      end
    }
  end

  #---------------------------------------------------------------------------------------------------------------------
  #  Parses the raw XML document.
  #---------------------------------------------------------------------------------------------------------------------
  def parse(raw_xml)
    @host_data = []
    REXML::Document.parse_stream(raw_xml.to_s, @parser)
  end

  private
  ###################
  # PRIVATE METHODS #
  ###################

  #---------------------------------------------------------------------------------------------------------------------
  # Adds the vulnerability data to the database
  #---------------------------------------------------------------------------------------------------------------------
  def add_to_vuln_db(vuln_data)
    begin
      id = vuln_data["id"].to_s.downcase.chomp
      unless (VulnInfo.where(:vuln_id => id).exists? or not Util.is_vulnerable(vuln_data["status"]))
        begin
          vuln_input_data = {
              :severity    => vuln_data["severity"],
              :title       => vuln_data["title"],
              :description => vuln_data["description"],
              :solution    => vuln_data["solution"],
              :cvss        => vuln_data["cvssScore"]
          }

          description                   = Util.process_db_input_array(vuln_data["description"], true)
          solution                      = Util.process_db_input_array(vuln_data["solution"], true)
          vuln_input_data[:description] = description
          vuln_input_data[:solution]    = solution

          VulnInfo.create(:vuln_id => id, :vuln_data => vuln_input_data)
        rescue Exception => e
          @logger.add_log_message "[!] vulnid: #{id}, vuln data: #{vuln_input_data.inspect}"
          Rails.logger.warn "[!] vulnid: #{id}, vuln data: #{vuln_input_data.inspect}"
          @logger.add_log_message "[!] Error in populating vuln map: #{e.backtrace}"
          Rails.logger.warn "[!] Error in populating vuln map: #{e.backtrace}"
        end
      end
    end
  end

end
