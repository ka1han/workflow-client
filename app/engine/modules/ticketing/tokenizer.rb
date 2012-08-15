#This class takes in a ticket and replaces predefined tokens with
#the actual data that will be posted to the ticketing system
class Tokenizer

  def initialize
    @tokens = build_default_tokens
  end

  def tokenize(ticket_data={}, ticket={}, custom_tokens={})
    tokenized_ticket = {}

    #if custom tokens were added by the user, merge them in
    #with the default tokens
    @tokens.merge! custom_tokens if custom_tokens

    ticket.each do |key, value|
      tokenized_ticket[key] = value

      @tokens.each do |token_key, token_value|

        #we can't replace tokens in :symbols since :symbols are immutable
        next if value.kind_of? Symbol

        if key == :body or key == :headers
          tokenized_ticket[key].each do |k,v|

            #this is hacky, but some of our data is stored in
            #hashes of hashes, the | denotes the level. Vuln title and desc
            #are in this category.
            #
            #only goes down two levels though.
            if token_value.kind_of? String and token_value.index('|')

              #tmp[0] == parent key
              #tmp[1] == child key
              tmp = token_value.split '|'
              
              if v.index(token_key)

                #makes sense! I promise
                #replace the token in the string in-place with the ticket data if the ticket data exists
                #otherwise replace it with an empty string
                tokenized_ticket[key][k].gsub!(token_key, ticket_data[tmp[0]][:"#{tmp[1]}"] || '')
              end
            else
              if v.index(token_key)

                #replace token with ticket data if it exists, or an empty string if not
                tokenized_ticket[key][k].gsub!(token_key, ticket_data[token_value] || '')
              end
            end
          end
        end
      end
    end

    tokenized_ticket
  end

  private
  def build_default_tokens
    tokens = {}

    #the symbols correlate to ticket data that is passed to the tokenizer
    tokens["$NODE_ADDRESS$"] = :ip
    tokens["$NODE_NAME$"] = :name
    tokens["$VENDOR$"] = :vendor
    tokens["$PRODUCT$"] = :product
    tokens["$FAMILY$"] = :fingerprint
    tokens["$VERSION$"] = :version
    tokens["$VULN_STATUS$"] = :vuln_status
    tokens["$VULN_ID$"] = :vuln_id
    tokens["$VULN_TITLE$"] = "vuln_data|vuln_title"
    tokens["$DESC$"] = "vuln_data|description"
    tokens["$PROOF$"] = :proof
    tokens["$SOLUTION$"] = :solution
    tokens["$SCAN_START$"] = :scan_start
    tokens["$SCAN_END$"] = :scan_end
    tokens["$CVSS_SCORE$"] = :cvss

    tokens
  end
end
