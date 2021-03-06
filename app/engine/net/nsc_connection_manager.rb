#-----------------------------------------------------------------------------------------------------------------------
# == Synopsis
# Singleton class that manages all Nexpose connections.
#
# == Author
# Christopher Lee, christopher_lee@rapid7.com
#-----------------------------------------------------------------------------------------------------------------------

require 'singleton'

class NSCConnectionManager
  include Singleton

  def initialize
    @nsc_connections = {}
    @logger = LogManager.instance

    # Now load all the connections
    nsc_configs = NscConfig.all

    added_connection = false
    nsc_configs.each do |nsc_config|
      if nsc_config.is_active?
        add_connection nsc_config
        added_connection = true
      end
    end

    if not nsc_configs or nsc_configs.empty?
      @logger.add_log_message "[!] There are no configured NSC connections"
      Rails.logger.warn "[!] There are no configured NSC connections"
    elsif not added_connection
      @logger.add_log_message "[!] There are no active NSC connections"
      Rails.logger.warn "[!] There are no active NSC connections"
    end
  end

  #-------------------------------------------------------------------------------------------------------------------
  # Adds a Nexpose connection
  #-------------------------------------------------------------------------------------------------------------------
  def add_connections conn_details
    conn_details.each do |conn_detail|
      add_connection conn_detail
    end
  end

  #-------------------------------------------------------------------------------------------------------------------
  # Removes a Nexpose connection
  #-------------------------------------------------------------------------------------------------------------------
  def remove_connection conn
    @nsc_connections.delete conn[:host]
    @logger.add_log_message "[!] Removed NSC Config for host \"#{conn[:host]}\""
    Rails.logger.warn "[!] Removed NSC Config for host \"#{conn[:host]}\""
    if @nsc_connections.empty?
      @logger.add_log_message "[-] There are no configured NSC connections!"
      Rails.logger.info "[-] There are no configured NSC connections!"
    end
  end

  #
  # @param conn - An NSCConfig record object
  #
  def update_connection conn
    if conn[:is_active]
      remove_connection conn
      add_connection conn
    end
    @logger.add_log_message "[*] Updated NSC connection for host \"#{conn[:host]}\""
    Rails.logger.info "[*] Updated NSC connection for host \"#{conn[:host]}\""
  end

  #
  #
  #
  def add_connection conn_detail
    # TODO: Resolve to IP so we don't store things like localhost/127.0.0.1
    if conn_detail[:is_active]
      host = conn_detail[:host].to_s.chomp
      @nsc_connections[host] = get_nexpose_connection conn_detail
      @logger.add_log_message "[*] Added ACTIVE NSC connection for host \"#{conn_detail[:host]}\""
      Rails.logger.info "[*] Added ACTIVE NSC connection for host \"#{conn_detail[:host]}\""
    else
      @logger.add_log_message "[-] Added NON-ACTIVE NSC connection for host \"#{conn_detail[:host]}\""
      Rails.logger.info "[-] Added NON-ACTIVE NSC connection for host \"#{conn_detail[:host]}\""
    end

  end


  # TODO: Do this better with proper resolution, store IP only if possible.
  def get_nsc_connection host
    @nsc_connections[host]
  end

  #
  #
  # TODO: Ensure values are not stale.
  #---------------------------------------------------------------------------------------------------------------------
  # Returns a map of the host-name to the wrapped connection object.
  #---------------------------------------------------------------------------------------------------------------------
  def get_nsc_connections
    @nsc_connections
  end

  #
  #
  #
  def self.is_alive? conn_details
    client_connection = Nexpose::Connection.new conn_details[:host], conn_details[:username], conn_details[:password], conn_details[:port]
    client_connection.login
    true
  rescue Exception
    false
  end

  #
  #
  #
  def get_nexpose_connection conn_details
    client_connection = Nexpose::Connection.new conn_details[:host], conn_details[:username], conn_details[:password], conn_details[:port]
    NexposeConnectionWrapper.new client_connection
  rescue Exception
    return nil
  end

  #
  # Builds a map of NSC host name to a list of users defined for that NSC
  #
  def get_host_user_map
    host_users = {}
    @nsc_connections.keys.each do |host|
      user_list = @nsc_connections[host].list_users
      if user_list and user_list.length > 0
        # we only want the user_names
        user_name_list = []
        user_list.each do |user_data|
          user_name_list << user_data[:user_name]
        end
        host_users[host] = user_name_list
      end
    end
    host_users
  end

  def get_user_array host
    host_users = get_host_user_map
    wrapped_user_array = []
    array_pos = 0
    if host_users[host]
      host_users[host].each do |user_name|
        wrapped_user_array << (WrappedUserData.new array_pos, user_name)
        array_pos = array_pos + 1
      end
    end
    wrapped_user_array
  end
end


#-----------------------------------------------------------------------------------------------------------------------
# Wraps the NeXpose::Connection objects, uses delegation for all API calls, this eases the detection of am invalid/stale
# session.
#-----------------------------------------------------------------------------------------------------------------------
class NexposeConnectionWrapper

  attr_accessor :log_errors

  def initialize nexpose_connection
    raise ArgumentError.new 'The nexpose connection cannot be null' unless nexpose_connection

    @nexpose_connection = nexpose_connection
    @logged_in = false
    @logger = LogManager.instance
    @failed_login_host_array = []
    @log_errors = true
  end

  #
  # Delegate all method calls through this method in order to wrap
  # session errors.
  #
  def method_missing method_name, *args
    #Only re-login once
    login_tries = 0
    ret = nil

    begin
      unless @logged_in
        begin
          @nexpose_connection.login
          @logged_in = true

          # If login successfull remove from failed login array.
          @failed_login_host_array.delete(@nexpose_connection.host)

          @logger.add_log_message "[!] Login to \"#{@nexpose_connection.host}\" successful"
          Rails.logger.info  "[!] Login to \"#{@nexpose_connection.host}\" successful"
        rescue Exception

          # If the failed attempt has already been logged, don't log again until a successfull login.
          # TODO: Add logic to purge this list after a time period to remind the user.
          host = @nexpose_connection.host
          if not @failed_login_host_array.include?(host)
            @logger.add_log_message "[-] Login to \"#{@nexpose_connection.host}\" has failed!"
            Rails.logger.warn "[-] Login to \"#{@nexpose_connection.host}\" has failed!"
            @failed_login_host_array << host
          end
        end
      end

      # Do not attempt API call if we are not logged in.
      if @logged_in
        ret = @nexpose_connection.send method_name, *args
      end
    rescue Nexpose::APIError => e
      if e.message =~ /session not found/i and login_tries < 1
        # We have a session error, relogin and try again
        @nexpose_connection.login
        login_tries = 1
        retry
      else
        if @log_errors
          @logger.add_log_message "[-] API call to #{method_name} has failed!"
          Rails.logger.warn "[-] API call to #{method_name} has failed!"
        end
      end
    end

    ret
  end
end

class WrappedUserData

  attr_accessor :id, :user_name

  def initialize id, user_name
    @id = id
    @user_name = user_name
  end

end
