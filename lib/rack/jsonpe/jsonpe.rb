require 'rack'

module Rack
  # A Rack middleware for providing JSONP in a usable way - accepts GET/POST/PUT/DELETE verbs and http status and
  # headers are readable from the body.
  #
  # Based on Rack-JSONP by Flinn Mueller (http://actsasflinn.com/)
  #
  class JSONPe
    include Rack::Utils

    def initialize(app)
      @app = app
    end

    # Proxies the request to the application, stripping out the JSONP callback
    # method and padding the response with the appropriate callback format if
    # the returned body is application/json
    #
    # Changes nothing if no <tt>callback</tt> param is specified.
    #
    def call(env)
      status, headers, response = @app.call(env)

      headers = HeaderHash.new(headers)
      request = Rack::Request.new(env)
      params = request.params

      if is_jsonp_request?(request) and params['request_method'].present?
        env['REQUEST_METHOD'] = params['request_method'].upcase if ['POST','PUT','DELETE'].include?(params['request_method'].upcase)
      end

      if is_jsonp_request?(request) and is_json_response?(headers)
        response = format_jsonp(request.params.delete('callback'), status, headers, response)
        status = 200

        # No longer json, its javascript!
        headers['Content-Type'] = headers['Content-Type'].gsub('json', 'javascript')

        # Set new Content-Length, if it was set before we mutated the response body
        if headers['Content-Length']
          length = response.to_ary.inject(0) { |len, part| len + bytesize(part) }
          headers['Content-Length'] = length.to_s
        end
      end
      [status, headers, response]
    end

    private

    def is_json_response?(headers)
      headers.key?('Content-Type') && headers['Content-Type'].include?('application/json')
    end

    def is_jsonp_request?(request)
      @is_jsonp_request ||= (request.params.include?('callback') and request.get?)
    end

    # Formats the JSONP padding to include body, headers and http status
    #
    def format_jsonp(callback, status, headers, response, x_headers={}, body='')
      headers.each {|k,v| x_headers[k] = v if (k =~ /^X-.+/i) }
      response.each {|v| body << v.to_s }
      ["#{callback}(#{body}, #{status}, #{x_headers})"]
    end

  end
end
