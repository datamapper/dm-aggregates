require 'spec_helper'

RSpec.describe DataMapper::Collection do
  supported_by :sqlite, :mysql, :postgres do
    let(:dragons)   { Dragon.all  }
    let(:countries) { Country.all }

    include_examples 'It Has Setup Resources'
    include_examples 'An Aggregatable Class'

    describe 'ignore invalid query' do
      let(:dragons) { Dragon.all.all(:id => []) }

      [ :size, :count ].each do |method|
        describe "##{method}" do
          subject { dragons.send(method) }

          it { is_expected.to eq(0) }
        end
      end

      describe '#min' do
        subject { dragons.min(:id) }

        it { is_expected.to be_nil }
      end

      describe '#max' do
        subject { dragons.max(:id) }

        it { is_expected.to be_nil }
      end

      describe '#avg' do
        subject { dragons.avg(:id) }

        it { is_expected.to be_nil }
      end

      describe '#sum' do
        subject { dragons.sum(:id) }

        it { is_expected.to be_nil }
      end

      describe '#aggregate' do
        subject { dragons.aggregate(:id) }

        it { is_expected.to eq([]) }
      end
    end

    context 'with collections created with Set operations' do
      let(:collection) { dragons.all(:name => 'George') | dragons.all(:name => 'Puff') }

      describe '#size' do
        subject { collection.size }

        it { is_expected.to eq(2) }
      end

      describe '#count' do
        subject { collection.count }

        it { is_expected.to eq(2) }
      end

      describe '#min' do
        subject { collection.min(:toes_on_claw) }

        it { is_expected.to eq(3) }
      end

      describe '#max' do
        subject { collection.max(:toes_on_claw) }

        it { is_expected.to eq(4) }
      end

      describe '#avg' do
        subject { collection.avg(:toes_on_claw) }

        it { is_expected.to eq(3.5) }
      end

      describe '#sum' do
        subject { collection.sum(:toes_on_claw) }

        it { is_expected.to eq(7) }
      end

      describe '#aggregate' do
        subject { collection.aggregate(:all.count, :name.count, :toes_on_claw.min, :toes_on_claw.max, :toes_on_claw.avg, :toes_on_claw.sum)}

        it { is_expected.to eq([ 2, 2, 3, 4, 3.5, 7 ]) }
      end
    end

    context 'with a collection limited to 1 result' do
      let(:dragons) { Dragon.all(:limit => 1) }

      describe '#size' do
        subject { dragons.size }

        it { is_expected.to eq(1) }
      end

      describe '#count' do
        subject { dragons.count }

        it do
          pending('TODO: make count apply to the limited collection. Currently limit applies after the count')
          is_expected.to eq(1)
        end

      end
    end

    context 'with the order reversed by the grouping field' do
      subject { dragons.aggregate(:birth_at, :all.count) }

      let(:dragons) { Dragon.all(:order => [ :birth_at.desc ]) }

      it 'displays the results in reverse order' do
        is_expected.to eq(Dragon.aggregate(:birth_at, :all.count).reverse)
      end
    end
  end
end
