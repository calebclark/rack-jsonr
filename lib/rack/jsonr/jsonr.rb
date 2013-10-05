require 'rack'

module Rack
  class JSONR
    # Based on Rack-JSONP by Flinn Mueller (http://actsasflinn.com/)
    include Rack::Utils

    HTTP_METHODS_TO_OVERRIDE = %w(HEAD PUT POST DELETE OPTIONS PATCH)
    METHOD_OVERRIDE_PARAM_KEY = '_method'.freeze
    HTTP_METHOD_OVERRIDE_HEADER = 'HTTP_X_HTTP_METHOD_OVERRIDE'.freeze

    def initialize(app, options={})
      @options = options
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

      self.class.intercept_method_override(env, request, params, @options[:method_override])

      if is_jsonp_request?(request)
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

    def self.intercept_method_override(env, request, params, override_scope)
      if is_jsonp_request?(request) or override_scope == :all
        method_override = (params[METHOD_OVERRIDE_PARAM_KEY] || env[HTTP_METHOD_OVERRIDE_HEADER]).to_s.upcase
        if HTTP_METHODS_TO_OVERRIDE.include?(method_override) and !env['rack.jsonr_method_override.original_method']
          env['rack.jsonr_method_override.original_method'] = env['REQUEST_METHOD']
          env['REQUEST_METHOD'] = method_override
        end
      end
    end

    def self.is_jsonp_request?(request)
      (request.params.include?('callback') and (request.get? or request.env['rack.jsonr_method_override.original_method'] == 'GET'))
    end

    private

    def is_json_response?(headers)
      headers.key?('Content-Type') && headers['Content-Type'].include?('application/json')
    end

    def is_jsonp_request?(request)
      @is_jsonp_request ||= self.class.is_jsonp_request?(request)
    end

    # Formats the JSONP padding to include body, headers and http status
    #
    def format_jsonp(callback, status, headers, response, x_headers={}, body='')
      headers.each {|k,v| x_headers[k] = v if (k =~ /^X-.+/i) }
      response.each {|v| body << v.to_s }
      ["#{callback}(#{body}, #{status}, #{x_headers.to_json})"]
    end

  end
end
