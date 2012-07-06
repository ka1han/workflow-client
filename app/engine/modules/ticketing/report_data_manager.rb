#-----------------------------------------------------------------------------------------------------------------------
# == Synopsis
# Provides a more robust mechanism to retrieve Nexpose raw xml report.
#
# == Author
# Christopher Lee christopher_lee@rapid7.com
# TODO: refactor to be more generic
#-----------------------------------------------------------------------------------------------------------------------
class ReportDataManager

  #---------------------------------------------------------------------------------------------------------------------
  # Sets the nexpose connection object
  #---------------------------------------------------------------------------------------------------------------------
  def initialize(nsc_connection)
    @nsc_connection = nsc_connection
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Gets the raw xml
  #---------------------------------------------------------------------------------------------------------------------
  def get_raw_xml_for_scan(scan_id)
    data = nil
    
    # Try ad hoc first and if it fails try the on disk method
    begin
      data = get_adhoc_for_scan(scan_id)
    rescue Exception => e
      # TODO: maybe log
    end

    #check to see if we have an empty report
    #if so, generate an ondisk report instead
    if data.nil? || data.to_s.length < 131
      data = get_on_disk_report_for_scan(scan_id) 
    end

    data
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Gets the raw xml via the adhoc mechanism
  #---------------------------------------------------------------------------------------------------------------------
  def get_adhoc_for_scan(scan_id)
    adhoc_report_generator = Nexpose::ReportAdHoc.new(@nsc_connection)
    adhoc_report_generator.addFilter('scan', scan_id)
    data = adhoc_report_generator.generate
    data
  end

  #---------------------------------------------------------------------------------------------------------------------
  # Gets the raw xml by generating the report on disk then pulling it across
  #---------------------------------------------------------------------------------------------------------------------
  def get_on_disk_report_for_scan(scan_id)
    data = nil
    report_config_name = "nexflow_report_config_#{scan_id}"
    report = Nexpose::ReportConfig.new(@nsc_connection)
    report.set_name(report_config_name)
    report.addFilter("scan", scan_id)
    report.set_storeOnServer(1)
    report.set_format("raw-xml-v2")

    begin
      resp = report.saveReport
    rescue Exception => e
      Rails.logger.warn e.message
      Rails.logger.warn e.backtrace
    end

    begin
      url = nil
      while !url
        url = @nsc_connection.report_last(report.config_id)

        #sleep to let nexpose catch up with itself
        #we may end up with empty reports if we don't
        sleep(60)
      end

      last_data_file_size = 0
      max_interval = 30
      count = 0

      while true
        while !data
          begin
            data = @nsc_connection.download(url)

            while data.length < 131 #130 is an empty report
              select(nil, nil, nil, 30)
              data = @nsc_connection.download(url)
            end
          rescue Exception => e
            Rails.logger.warn e.message
            Rails.logger.warn e.backtrace
            data = nil
          end
        end

        if data
          current_file_size = data.length
          if current_file_size > last_data_file_size
            last_data_file_size = current_file_size
            count = 0
          else
            if count > max_interval
              break
            end
            count += 1
          end

          # Validate report completion
          if data.index("<NexposeReport") and data.index("</NexposeReport>")
            break
          end
        else
          if count > max_interval
            break
          end
          count += 1
        end
        sleep(1)
      end
    rescue Exception => e
      Rails.logger.warn e.message
      Rails.logger.warn e.backtrace
    ensure
      begin
        @nsc_connection.report_config_delete(report.config_id)
      rescue
        Rails.logger.warn "Unable to remove report config, please removed config manually #{report.config_id}"
      end
    end

    data
  end
end
