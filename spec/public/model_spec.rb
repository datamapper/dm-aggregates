require 'spec_helper'

RSpec.describe DataMapper::Model do
  supported_by :sqlite, :mysql, :postgres do
    let(:dragons)   { Dragon  }
    let(:countries) { Country }

    include_examples 'It Has Setup Resources'
    include_examples 'An Aggregatable Class'
  end
end
