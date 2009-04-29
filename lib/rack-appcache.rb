require 'find'

# HACKKKKARGHZ

module Rack
  class AppCache
    def initialize(app, options={})
      @app = app
      @options = options
      @options[:manifest] ||= '/manifest'
      @options[:purge] ||= '/purge-manifest'
    end

    def call(env)
      return serve_manifest(env) if env['PATH_INFO'] == @options[:manifest]

      env['app-cache.manifest'] = StringIO.new(manifest)

      status, headers, body = @app.call(env)

      if env['app-cache.manifest'].nil?
        @manifest = nil
      end

      if env['PATH_INFO'] != @options[:purge] and (200..300).include?(status)
        update_manifest(env)
      end

      Rack::Response.new(body, status, headers).finish
    end

    def update_manifest(env)
      return if manifest.split("\n").include?(env['PATH_INFO'])
      manifest << "\n"
      manifest << env['PATH_INFO']
    end

    def serve_manifest(env)
      # return [404, {'Content-Type' => 'text/html'}, []] # reset
      status, headers, body = @app.call(env)
      headers['Content-Type'] = 'text/cache-manifest'
      response = Rack::Response.new(manifest, 200, headers)
      response.finish
    end

    def manifest
      @manifest ||= build_manifest
    end

    private

    def build_manifest
      paths = []
      paths << 'CACHE MANIFEST'
      Array(@options[:include]).each do |dir|
        Find.find(dir) { |path| paths << path.gsub(dir, '') }
      end
      paths.join("\n")
    end
  end
end
