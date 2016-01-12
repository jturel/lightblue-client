desc 'Lightblue'

namespace :lightblue do
  def jpp(json)
    puts JSON.pretty_generate(json)
  end

  def options
    defined?(Rails) ? [:environment] : [:init]
  end

  task :init do
    fail 'Set LIGHTBLUE_HOST and LIGHTBLUE_METADATA_PATH env variables to run' if !ENV['LIGHTBLUE_HOST'] && !ENV['LIGHTBLUE_METADATA_PATH']

    Lightblue.configure do |c|
      c.host_uri = ENV['LIGHTBLUE_HOST']
      c.metadata_path = ENV['LIGHTBLUE_METADATA_PATH']
    end
  end

  namespace :metadata do
    desc 'List Entities. Usage: STATUS=[active | disabled | deprecated ]'
    task entities: options do
      jpp Lightblue::Metadata.entities(ENV['STATUS'])
    end

    desc 'Create Entity. Usage: [ENTITY=entity, VERSION=version]'
    task create: options do
      entity = ENV['ENTITY']
      version = ENV['VERSION']
      metadata = Lightblue::Metadata.local_metadata(entity, version)
      Lightblue::Metadata.create_metadata(entity, version, metadata)
    end

    desc 'Delete Entity. Usage: [ENTITY=entity, VERSION=version]'
    task delete: options do
      entity = ENV['ENTITY']
      version = ENV['VERSION']
      Lightblue::Metadata.disable_all(entity, version)
      Lightblue::Metadata.delete_metadata(entity)
    end
  end

  namespace :entity do
    desc 'Get versions for entity'
    task versions: options do
      entity = ENV['ENTITY']
      fail 'Must define env["ENTITY"]' if entity.nil?
      jpp Lightblue::Metadata.versions(entity)
    end

    desc 'Get metadata for entity:version. Usage: ENTITIY=entity, VERSION=version'
    task metadata: options do
      jpp Lightblue::Metadata.metadata(ENV['ENTITY'], ENV['VERSION'])
    end

    desc 'Get dependencies for entity:version Usage: [ENTITIY=entity [VERSION=version]]'
    task dependencies: options do
      jpp Lightblue::Metadata.dependencies(ENV['ENTITY'], ENV['VERSION'])
    end

    desc 'Get roles for entity:version. Usage: [ENTITIY=entity [VERSION=version]]'
    task roles: options do
      jpp Lightblue::Metadata.roles(ENV['ENTITY'], ENV['VERSION'])
    end
  end
end
