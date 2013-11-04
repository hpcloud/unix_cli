# encoding: utf-8
#
# © Copyright 2013 Hewlett-Packard Development Company, L.P.
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'fog/hp'

module Fog
  module HP
    class LB < Fog::Service

      requires :hp_secret_key, :hp_tenant_id, :hp_avl_zone
      recognizes :hp_auth_uri, :credentials
      recognizes :persistent, :connection_options
      recognizes :hp_use_upass_auth_style, :hp_auth_version, :user_agent
      recognizes :hp_access_key, :hp_account_id # :hp_account_id is deprecated use hp_access_key instead

      secrets :hp_secret_key

      model_path 'monkey/hp/models/lb'
      model       :algorithm
      collection  :algorithms
      model       :limit
      collection  :limits
      model       :load_balancer
      collection  :load_balancers
      model       :node
      collection  :nodes
      model       :protocol
      collection  :protocols
      model       :version
      collection  :versions
      model       :virtual_ip
      collection  :virtual_ips

      request_path 'monkey/hp/requests/lb'
      request       :create_load_balancer
      request       :create_load_balancer_node
      request       :delete_load_balancer
      request       :delete_load_balancer_node
      request       :get_load_balancer
      request       :get_load_balancer_node
      request       :get_version
      request       :get_virtual_ips
      request       :list_algorithms
      request       :list_limits
      request       :list_load_balancer_nodes
      request       :list_load_balancers
      request       :list_protocols
      request       :list_versions
      request       :list_load_balancer_virtual_ips
      request       :update_load_balancer
      request       :update_load_balancer_node

      class Mock


        def self.data
          @data ||= Hash.new do |hash, key|
            hash[key] = {

            }
          end
        end

        def self.reset
          @data = nil
        end

        def initialize(options={})
          # deprecate hp_account_id
          if options[:hp_account_id]
            Fog::Logger.deprecation(":hp_account_id is deprecated, please use :hp_access_key instead.")
            @hp_access_key = options.delete(:hp_account_id)
          end
          @hp_access_key = options[:hp_access_key]
          unless @hp_access_key
            raise ArgumentError.new("Missing required arguments: hp_access_key. :hp_account_id is deprecated, please use :hp_access_key instead.")
          end
        end

        def data
          self.class.data[@hp_access_key]
        end

        def reset_data
          self.class.data.delete(@hp_access_key)
        end

      end

      class Real
        attr_reader :credentials


        def initialize(options={})
          # deprecate hp_account_id
          if options[:hp_account_id]
            Fog::Logger.deprecation(":hp_account_id is deprecated, please use :hp_access_key instead.")
            options[:hp_access_key] = options.delete(:hp_account_id)
          end
          @hp_access_key = options[:hp_access_key]
          unless @hp_access_key
            raise ArgumentError.new("Missing required arguments: hp_access_key. :hp_account_id is deprecated, please use :hp_access_key instead.")
          end
          @hp_secret_key      = options[:hp_secret_key]
          @hp_auth_uri        = options[:hp_auth_uri]
          @connection_options = options[:connection_options] || {}
          ### Set an option to use the style of authentication desired; :v1 or :v2 (default)
          auth_version        = options[:hp_auth_version] || :v2
          ### Pass the service name for object storage to the authentication call
          options[:hp_service_type] = "Load Balancer"
          @hp_tenant_id       = options[:hp_tenant_id]
          @hp_avl_zone        = options[:hp_avl_zone]

          ### Make the authentication call
          if (auth_version == :v2)
            # Call the control services authentication
            credentials = Fog::HP.authenticate_v2(options, @connection_options)
            # the CS service catalog returns the block storage endpoint
            @hp_block_uri = credentials[:endpoint_url]
          else
            # Call the legacy v1.0/v1.1 authentication
            credentials = Fog::HP.authenticate_v1(options, @connection_options)
            # the user sends in the block storage endpoint
            @hp_block_uri = options[:hp_auth_uri]
          end

          @auth_token = credentials[:auth_token]
          @persistent = options[:persistent] || false

          uri = URI.parse(@hp_block_uri)
          @host   = uri.host
          @path   = uri.path
          @port   = uri.port
          @scheme = uri.scheme

          @connection = Fog::Connection.new("#{@scheme}://#{@host}:#{@port}", @persistent, @connection_options)
        end

        def reload
          @connection.reset
        end

        def request(params, parse_json = true, &block)
          begin
            response = @connection.request(params.merge!({
                                                             :headers => {
                                                                 'Content-Type' => 'application/json',
                                                                 'X-Auth-Token' => @auth_token
                                                             }.merge!(params[:headers] || {}),
                                                             :path    => "#{@path}/#{params[:path]}",
                                                         }), &block)
          rescue Excon::Errors::HTTPStatusError => error
            raise case error
                    when Excon::Errors::NotFound
                      Fog::HP::BlockStorage::NotFound.slurp(error)
                    else
                      error
                  end
          end
          if !response.body.empty? && parse_json && response.headers['Content-Type'] =~ %r{application/json}
            response.body = Fog::JSON.decode(response.body)
          end
          response
        end

      end

    end
  end
end
