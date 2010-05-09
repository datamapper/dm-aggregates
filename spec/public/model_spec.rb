require 'spec_helper'

describe DataMapper::Model do

  before :all do
    @dragons   = Dragon
    @countries = Country
  end

  supported_by :sqlite, :mysql, :postgres do
    it_should_behave_like 'It Has Setup Resources'
    it_should_behave_like 'An Aggregatable Class'
  end
end
