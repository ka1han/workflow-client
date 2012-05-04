class VulnInfo < ActiveRecord::Base
	serialize :vuln_data, Hash

  #---------------------------------------------------------------------------------------------------------------------
  # Retrieves the vulnerability title for an ID otherwise null.
  #
  # vuln_id - The nexpose vulnerability ID.
  #---------------------------------------------------------------------------------------------------------------------
  def VulnInfo.get_vuln_title(vuln_id)
    vuln_info = VulnInfo.find_by_vuln_id(vuln_id)
    if vuln_info
      return vuln_info[:vuln_data][:title]
    end

    nil
  end

end
