require 'dm-core'

require 'dm-aggregates/adapters/data_objects_adapter'
require 'dm-aggregates/aggregate_functions'
require 'dm-aggregates/collection'
require 'dm-aggregates/core_ext/symbol'
require 'dm-aggregates/model'
require 'dm-aggregates/query'
require 'dm-aggregates/repository'

begin
  require 'active_support/core_ext/time/conversions'
rescue LoadError
  require 'extlib/time'
end

module DataMapper
  class Repository
    include Aggregates::Repository
  end

  module Model
    include Aggregates::Model
  end

  class Collection
    include Aggregates::Collection
  end

  class Query
    include Aggregates::Query
  end

  module Adapters
    extendable do

      # TODO: document
      # @api private
      def const_added(const_name)
        if DataMapper::Aggregates.const_defined?(const_name)
          adapter = const_get(const_name)
          adapter.send(:include, DataMapper::Aggregates.const_get(const_name))
        end

        super
      end
    end
  end # module Adapters
end # module DataMapper
