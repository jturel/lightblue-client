require 'json'
module Lightblue
  module Metadata
    ENDPOINT = 'rest'

    def self.connection(url = Lightblue.options[:host_uri], options = {}, &block)
      Faraday.new(url, options) do |f|
        f.response :logger
        f.adapter Faraday.default_adapter
        block.call(f) if block
      end
    end

    def self.get(url, params = nil, headers = nil)
      url = ENDPOINT + url
      connection.get(url, params, headers) do |req|
        yield(req) if block_given?
      end
    end

    def self.put(url, body = nil, headers = nil)
      connection.put(url, body, headers) do |req|
        yield(req) if block_given?
      end
    end

    def self.delete(url, headers = nil)
      connection.delete(url, headers) do |req|
        yield(req) if block_given?
      end
    end

    def self.disable_all(entity, versions)
      versions = versions(entity).map { |e| e['version'] }
      versions.each do |v|
        url = format('%s/%s/%s/%s/%s', ENDPOINT, 'metadata', entity, v, :disabled)
        put(url)
      end
    end

    def self.delete_metadata(entity)
      url = format('%s/%s/%s', ENDPOINT, 'metadata', entity)
      delete(url)
    end

    def self.create_metadata(entity, version, json)
      url = format('%s/%s/%s/%s', ENDPOINT, 'metadata', entity, version)
      put(url, json.to_json, 'content-type' => 'application/json')
    end

    def self.entities(status = nil)
      url = '/metadata' + (status ? "/s=#{status}" : '')
      JSON.parse get(url).body
    end

    def self.versions(entity)
      JSON.parse get("/metadata/#{entity}").body
    end

    def self.local_metadata(entity, version)
      path = Pathname.new(File.expand_path Lightblue.metadata_path).join(entity).join("#{version}.json")

      fail 'Entity Metadata does not exist' unless File.exist?(path)
      json = JSON.parse(File.read(path))
      errors = validate_metadata(json)
      fail "Invalid Schema. #{errors}" unless errors.empty?
      json
    end

    def self.metadata(entity, version)
      JSON.parse get("/metadata/#{entity}/#{version}").body
    end

    def self.dependencies(entity = nil, version = nil)
      JSON.parse get_arity2('dependencies', entity, version).body
    end

    def self.roles(entity = nil, version = nil)
      JSON.parse get_arity2('roles', entity, version).body
    end

    def self.get_arity2(ep, arg1 = nil, arg2 = nil)
      url = if !arg1
              '/metadata/'
            elsif !arg2
              "/metadata/#{arg1}/"
            else
              "/metadata/#{arg1}/#{arg2}/"
            end

      get(url + ep)
    end
    private_class_method :get_arity2

    def self.validate_metadata(json)
      manifest = Lightblue.resources.join('json-schema/manifest.json')
      metadata = JSON.parse(File.read(manifest))
      v = JSON::Validator
      v.fully_validate(metadata, json, fragment: '#/definitions/metadata/definitions/metadata')
    end
  end
end
