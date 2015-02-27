RSpec.shared_examples_for 'It Has Setup Resources' do
  before :all do
    @mysql    = defined?(DataMapper::Adapters::MysqlAdapter)    && @adapter.kind_of?(DataMapper::Adapters::MysqlAdapter)
    @postgres = defined?(DataMapper::Adapters::PostgresAdapter) && @adapter.kind_of?(DataMapper::Adapters::PostgresAdapter)

    @skip = (@mysql || @postgres) && ENV['TZ'].to_s.downcase != 'utc'
  end

  before :all do
    DataMapper.auto_migrate!

    @birth_at   = DateTime.now
    @birth_on   = Date.parse(@birth_at.to_s)
    @birth_time = Time.parse(@birth_at.to_s)

    @chuck = Knight.create(:name => 'Chuck')
    @larry = Knight.create(:name => 'Larry')

    Dragon.create(:name => 'George', :is_fire_breathing => false, :toes_on_claw => 3, :birth_at => @birth_at, :birth_on => @birth_on, :birth_time => @birth_time, :knight => @chuck)
    Dragon.create(:name => 'Puff',   :is_fire_breathing => true,  :toes_on_claw => 4, :birth_at => @birth_at, :birth_on => @birth_on, :birth_time => @birth_time, :knight => @larry)
    Dragon.create(:name => nil,      :is_fire_breathing => true,  :toes_on_claw => 5, :birth_at => nil,       :birth_on => nil,       :birth_time => nil)

    gold_kilo_price   = 277738.70
    @gold_tonne_price = gold_kilo_price * 10000

    Country.create(
      :name                => 'China',
      :population          => 1330044605,
      :birth_rate          => 13.71,
      :gold_reserve_tonnes => 600.0,
      :gold_reserve_value  => 600.0 * @gold_tonne_price  # => 32150000
    )

    Country.create(
      :name                => 'United States',
      :population          => 303824646,
      :birth_rate          => 14.18,
      :gold_reserve_tonnes => 8133.5,
      :gold_reserve_value  => 8133.5 * @gold_tonne_price
    )

    Country.create(
      :name                => 'Brazil',
      :population          => 191908598,
      :birth_rate          => 16.04,
      :gold_reserve_tonnes => nil  # example of no stats available
    )

    Country.create(
      :name                => 'Russia',
      :population          => 140702094,
      :birth_rate          => 11.03,
      :gold_reserve_tonnes => 438.2,
      :gold_reserve_value  => 438.2 * @gold_tonne_price
    )

    Country.create(
      :name                => 'Japan',
      :population          => 127288419,
      :birth_rate          => 7.87,
      :gold_reserve_tonnes => 765.2,
      :gold_reserve_value  => 765.2 * @gold_tonne_price
    )

    Country.create(
      :name                => 'Mexico',
      :population          => 109955400,
      :birth_rate          => 20.04,
      :gold_reserve_tonnes => nil  # example of no stats available
    )

    Country.create(
      :name                => 'Germany',
      :population          => 82369548,
      :birth_rate          => 8.18,
      :gold_reserve_tonnes => 3417.4,
      :gold_reserve_value  => 3417.4 * @gold_tonne_price
    )

    @approx_by = 0.0001
  end
end

RSpec.shared_examples_for 'An Aggregatable Class' do
  describe '#size' do
    include_examples 'count with no arguments'
  end

  describe '#count' do
    include_examples 'count with no arguments'

    context 'with a property name' do
      it 'counts the results' do
        expect(dragons.count(:name)).to eq(2)
      end

      it 'counts the results with conditions having operators' do
        expect(dragons.count(:name, :toes_on_claw.gt => 3)).to eq(1)
      end

      it 'counts the results with raw conditions' do
        statement = 'is_fire_breathing = ?'
        expect(dragons.count(:name, :conditions => [ statement, false ])).to eq(1)
        expect(dragons.count(:name, :conditions => [ statement, true  ])).to eq(1)
      end
    end
  end

  describe '#min' do
    context 'with no arguments' do
      it 'raises an error' do
        expect { dragons.min }.to raise_error(ArgumentError)
      end
    end

    context 'with a property name' do
      it 'provides the lowest value of an Integer property' do
        expect(dragons.min(:toes_on_claw)).to eq(3)
        expect(countries.min(:population)).to eq(82369548)
      end

      it 'provides the lowest value of a Float property' do
        expect(countries.min(:birth_rate)).to be_kind_of(Float)
        expect(countries.min(:birth_rate)).to be >= 7.87 - @approx_by  # approx match
        expect(countries.min(:birth_rate)).to be <= 7.87 + @approx_by  # approx match
      end

      it 'provides the lowest value of a BigDecimal property' do
        expect(countries.min(:gold_reserve_value)).to be_kind_of(BigDecimal)
        expect(countries.min(:gold_reserve_value)).to eq(BigDecimal('1217050983400.0'))
      end

      it 'provides the lowest value of a DateTime property' do
        pending_if 'TODO: returns incorrect value until DO handles TZs properly', @skip do
          expect(dragons.min(:birth_at)).to be_kind_of(DateTime)
          expect(dragons.min(:birth_at).to_s).to eq(@birth_at.to_s)
        end
      end

      it 'provides the lowest value of a Date property' do
        expect(dragons.min(:birth_on)).to be_kind_of(Date)
        expect(dragons.min(:birth_on)).to eq(@birth_on)
      end

      it 'provides the lowest value of a Time property' do
        expect(dragons.min(:birth_time)).to be_kind_of(Time)
        expect(dragons.min(:birth_time).to_s).to eq(@birth_time.to_s)
      end

      it 'provides the lowest value when conditions provided' do
        expect(dragons.min(:toes_on_claw, :is_fire_breathing => true)).to  eq(4)
        expect(dragons.min(:toes_on_claw, :is_fire_breathing => false)).to eq(3)
      end
    end
  end

  describe '#max' do
    context 'with no arguments' do
      it 'raises an error' do
        expect { dragons.max }.to raise_error(ArgumentError)
      end
    end

    context 'with a property name' do
      it 'provides the highest value of an Integer property' do
        expect(dragons.max(:toes_on_claw)).to eq(5)
        expect(countries.max(:population)).to eq(1330044605)
      end

      it 'provides the highest value of a Float property' do
        expect(countries.max(:birth_rate)).to be_kind_of(Float)
        expect(countries.max(:birth_rate)).to be >= 20.04 - @approx_by  # approx match
        expect(countries.max(:birth_rate)).to be <= 20.04 + @approx_by  # approx match
      end

      it 'provides the highest value of a BigDecimal property' do
        expect(countries.max(:gold_reserve_value)).to eq(BigDecimal('22589877164500.0'))
      end

      it 'provides the highest value of a DateTime property' do
        pending_if 'TODO: returns incorrect value until DO handles TZs properly', @skip do
          expect(dragons.min(:birth_at)).to be_kind_of(DateTime)
          expect(dragons.min(:birth_at).to_s).to eq(@birth_at.to_s)
        end
      end

      it 'provides the highest value of a Date property' do
        expect(dragons.min(:birth_on)).to be_kind_of(Date)
        expect(dragons.min(:birth_on)).to eq(@birth_on)
      end

      it 'provides the highest value of a Time property' do
        expect(dragons.min(:birth_time)).to be_kind_of(Time)
        expect(dragons.min(:birth_time).to_s).to eq(@birth_time.to_s)
      end

      it 'provides the highest value when conditions provided' do
        expect(dragons.max(:toes_on_claw, :is_fire_breathing => true)).to  eq(5)
        expect(dragons.max(:toes_on_claw, :is_fire_breathing => false)).to eq(3)
      end
    end
  end

  describe '#avg' do
    context 'with no arguments' do
      it 'raises an error' do
        expect { dragons.avg }.to raise_error(ArgumentError)
      end
    end

    context 'with a property name' do
      it 'provides the average value of an Integer property' do
        expect(dragons.avg(:toes_on_claw)).to be_kind_of(Float)
        expect(dragons.avg(:toes_on_claw)).to eq(4.0)
      end

      it 'provides the average value of a Float property' do
        mean_birth_rate = (13.71 + 14.18 + 16.04 + 11.03 + 7.87 + 20.04 + 8.18) / 7
        expect(countries.avg(:birth_rate)).to be_kind_of(Float)
        expect(countries.avg(:birth_rate)).to be >= mean_birth_rate - @approx_by  # approx match
        expect(countries.avg(:birth_rate)).to be <= mean_birth_rate + @approx_by  # approx match
      end

      it 'provides the average value of a BigDecimal property' do
        mean_gold_reserve_value = ((600.0 + 8133.50 + 438.20 + 765.20 + 3417.40) * @gold_tonne_price) / 5
        expect(countries.avg(:gold_reserve_value)).to be_kind_of(BigDecimal)
        expect(countries.avg(:gold_reserve_value)).to eq(BigDecimal(mean_gold_reserve_value.to_s))
      end

      it 'provides the average value when conditions provided' do
        expect(dragons.avg(:toes_on_claw, :is_fire_breathing => true)).to  eq(4.5)
        expect(dragons.avg(:toes_on_claw, :is_fire_breathing => false)).to eq(3)
      end
    end
  end

  describe '#sum' do
    context 'with no arguments' do
      it 'raises an error' do
        expect { dragons.sum }.to raise_error(ArgumentError)
      end
    end

    context 'with a property name' do
      it 'provides the sum of values for an Integer property' do
        expect(dragons.sum(:toes_on_claw)).to eq(12)

        total_population = 1330044605 + 303824646 + 191908598 + 140702094 +
                           127288419 + 109955400 + 82369548
        expect(countries.sum(:population)).to eq(total_population)
      end

      it 'provides the sum of values for a Float property' do
        total_tonnes = 600.0 + 8133.5 + 438.2 + 765.2 + 3417.4
        expect(countries.sum(:gold_reserve_tonnes)).to be_kind_of(Float)
        expect(countries.sum(:gold_reserve_tonnes)).to be >= total_tonnes - @approx_by  # approx match
        expect(countries.sum(:gold_reserve_tonnes)).to be <= total_tonnes + @approx_by  # approx match
      end

      it 'provides the sum of values for a BigDecimal property' do
        expect(countries.sum(:gold_reserve_value)).to eq(BigDecimal('37090059214100.0'))
      end

      it 'provides the average value when conditions provided' do
        expect(dragons.sum(:toes_on_claw, :is_fire_breathing => true)).to  eq(9)
        expect(dragons.sum(:toes_on_claw, :is_fire_breathing => false)).to eq(3)
      end
    end
  end

  describe '#aggregate' do
    context 'with no arguments' do
      it 'raises an error' do
        expect { dragons.aggregate }.to raise_error(ArgumentError)
      end
    end

    context 'with only aggregate fields specified' do
      it 'provides aggregate results' do
        results = dragons.aggregate(:all.count, :name.count, :toes_on_claw.min, :toes_on_claw.max, :toes_on_claw.avg, :toes_on_claw.sum)
        expect(results).to eq([ 3, 2, 3, 5, 4.0, 12 ])
      end
    end

    context 'with aggregate fields and a property to group by' do
      it 'provides aggregate results' do
        results = dragons.aggregate(:all.count, :name.count, :toes_on_claw.min, :toes_on_claw.max, :toes_on_claw.avg, :toes_on_claw.sum, :is_fire_breathing)
        expect(results).to eq([ [ 1, 1, 3, 3, 3.0, 3, false ], [ 2, 1, 4, 5, 4.5, 9, true ] ])
      end
    end
  end

  describe 'query path issue' do
    it 'does not break when a query path is specified' do
      dragon = dragons.first(Dragon.knight.name => 'Chuck')
      expect(dragon.name).to eq('George')
    end
  end
end

RSpec.shared_examples_for 'count with no arguments' do
  it 'counts the results' do
    expect(dragons.count).to  eq(3)

    expect(countries.count).to eq(7)
  end

  it 'counts the results with conditions having operators' do
    expect(dragons.count(:toes_on_claw.gt => 3)).to eq(2)

    expect(countries.count(:birth_rate.lt => 12)).to eq(3)
    expect(countries.count(:population.gt => 1000000000)).to eq(1)
    expect(countries.count(:population.gt => 2000000000)).to eq(0)
    expect(countries.count(:population.lt => 10)).to eq(0)
  end

  it 'counts the results with raw conditions' do
    dragon_statement = 'is_fire_breathing = ?'
    expect(dragons.count(:conditions => [ dragon_statement, false ])).to eq(1)
    expect(dragons.count(:conditions => [ dragon_statement, true  ])).to eq(2)
  end
end
