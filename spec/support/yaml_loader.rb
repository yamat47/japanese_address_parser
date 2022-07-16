# frozen_string_literal: true

require 'yaml'

module YamlLoader
  def slice_load(file)
    if ::ENV.fetch('CI_NODE_TOTAL', nil) && ::ENV.fetch('CI_NODE_INDEX', nil)
      slice_size = Integer(::ENV.fetch('CI_NODE_TOTAL'), 10)
      index = Integer(::ENV.fetch('CI_NODE_INDEX'), 10)
    else
      slice_size = 1
      index = 0
    end

    ::YAML.load_file(file)
          .each_slice(slice_size)
          .map { |array| array[index] }
          .compact
  end

  module_function :slice_load
end
