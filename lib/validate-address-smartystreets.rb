require 'validate'
require 'validate/validations'
require 'smarty_streets'

module Validate

  class ValidationMethods

    # Validates an address using the SmartyStreets API.
    #
    # An address can have two representations: as a string, or as a structured
    # object. Structured objects have these keys:
    #
    # street: the street address, one line (e.g. "1 Main St\nSte 200")
    # city: e.g. "San Francisco"
    # state: two-digit code, e.g. "CA"
    # country: two-digit code, e.g. "US"
    # zip: postal code as a String, e.g. "94158"
    #
    # Note: this method will clean the address in-place. Careful with this, it
    # *will* mutate your source data.
    #
    # Failures will have this format:
    #
    #   ['was not a recognizable address. suggestions:', [
    #     {street: ..., city: ..., state: ..., country: ..., zip: ...}, ...
    #   ]]
    #
    fails_because_key do
      f = obj[field].instance_variable_get(:@ValidateAddressFailures)
      next 'could not be validated as an address.' unless f
      obj[field].remove_instance_variable(:@ValidateAddressFailures)
      f
    end
    #
    def validates_and_cleans_address(obj, field, opts, validator)

      address = obj[field]

      # validate data types
      unless address.is_a?(Hash) || address.is_a?(String)
        address.instance_variable_set(:@ValidateAddressFailures,
                                      ['must be either an address string or hash.'])
        return false
      end

      # only US is valid for now
      if address.is_a?(Hash) && (address[:country] || address['country']) != 'US'
        address.instance_variable_set(:@ValidateAddressFailures,
                                      ['must be a US address.'])
        return false
      end

      result, match, suggestions = Address.verify(address)

      unless result == true
        address.instance_variable_set(:@ValidateAddressFailures, [
          'was not a deliverable address. suggestions:',
          suggestions
        ])
        return false
      end

      # modify address in-place
      obj[field] = match
      true
    end
  end

  module Address

    # This performs the actual validation.
    #
    # An address is considered valid when SmartyStreets returns:
    # 1. Exactly one match.
    # 2. That match is verified as DPV deliverable.
    #
    # Returns a [valid, match, suggestions] tuple.
    #
    def self.verify(address)
      address = case address
                when Hash then address
                when String
                  {street: address}
                end
      matches = SmartyStreets.standardize do |s|
        x = nil
        s.street   = x if x = address[:street] || address['street']
        s.city     = x if x = address[:city]   || address['city']
        s.state    = x if x = address[:state]  || address['state']
        s.zip_code = x if x = address[:zip]    || address['zip']
      end

      format_suggestion = lambda do |s|
        {
          'street'  => s.street,
          'city'    => s.city,
          'state'   => s.state,
          'zip'     => s.zip_code,
          'country' => 'US',
        }
      end

      case matches.count
      when 0
        [false, nil, nil]
      when 1
        suggestion = matches.map(&format_suggestion)
        unless matches.first.analysis['dpv_match_code'] == 'Y'
          [false, nil, suggestion]
        else
          [true, suggestion.first, nil]
        end
      else
        [false, nil, matches.map(&format_suggestion)]
      end
    end
  end
end
