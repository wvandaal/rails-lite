require 'uri'

class Params
  KEY_PARSE_REGEX = /(?<head>.*)\[(?<rest>.*)\]/

  def initialize(req, route_params = {})
    @params = route_params
    @params.merge!(parse_www_encoded_form(req.body)) if req.body
    @params.merge!(parse_www_encoded_form(req.query_string)) if req.query_string
  end

  def [](key)
    @params[key]
  end

  def to_s
    @params.to_json
  end

  private
  def parse_www_encoded_form(www_encoded_form)
    params_hash = Hash[URI.decode_www_form(www_encoded_form)]
    params = {}
    params_hash.each do |key, val|
      buffer = params
      keys = parse_key(key)

      keys.each_with_index do |k, i|
        if keys.length == i + 1
          buffer[k] = val
        else
          buffer[k] ||= {}
          buffer = buffer[k]
        end
      end
    end
    params
  end

  def parse_key(key)
    match = KEY_PARSE_REGEX.match(key)
    match ? parse_key(match["head"]).push(match["rest"]) : [key]
  end
end
