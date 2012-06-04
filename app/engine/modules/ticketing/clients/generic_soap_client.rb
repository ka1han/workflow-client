require_relative '../../../net/wsdl_parser'
require_relative '../../../net/wsdl_utility'

require 'savon'
require 'rexml/document'
require File.expand_path(File.join(File.dirname(__FILE__), 'ticket_client'))

class GenericSoapClient < TicketClient

  attr_accessor :actions

  def initialize ticket_data
    #@ticket_data = ticket_data
  end

  def configure config
    @client = Savon::Client.new do

      #grab the wsdl that was uploaded
      wsdl.document = File.expand_path(File.join(File.dirname(__FILE__), "../../../../../public/uploads/" + config.mappings[:wsdl_file_name]))
    end

    @parser = WSDLParser.parse @client.wsdl.xml
    service = config.mappings[:service]
    op = config.mappings[:operation]

    @parser.bindings.each do |binding|
      next if not binding["name"] == service

      binding["children"].each do |child|
        next if not child["name"] == op

        child["children"].each do |action|
          next unless action["element_name"] =~ /operation/
          @action = action["soapAction"]
        end
      end
    end

    #@target_namespace = @parser.wsdl_definitions["targetNamespace"]
    #@wsdl_util = WSDLUtil.new @parser
    #@actions = @wsdl_util.get_soap_input_operations true
  end

  def create_ticket ticket_data 

    #we need a body before continuing
    raise "No ticket body" if not ticket_data[:body]

    action = @action

    begin
      #this might throw an exception if the soap request fails
      #so we catch the exception below, log it, then return the exception
      resp = @client.request :urn, ticket_data[:operation] do
        http.headers["SOAPAction"] = action
        soap.input = [ "urn:" + ticket_data[:operation], {} ]
        soap.header = ticket_data[:headers] || {} #we don't need headers all the time
        soap.body = ticket_data[:body]
      end

      ret = {}
      ret[:status] = true
      ret[:response] = resp #go ahead and return the response in case we need something from it later

      return ret
    rescue Exception => e

      #this will log the error to the environment log
      Rails.logger.warn e.message
      ret = {}
      ret[:status] = false
      ret[:error] = e.message

      return ret
    end
  end
end
