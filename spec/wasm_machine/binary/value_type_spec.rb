RSpec.describe WasmMachine::Binary::ValueType do
  describe ".from" do
    subject { described_class.from(byte) }

    context "byte is 0x7F" do
      let(:byte) { 0x7F }
      it { is_expected.to eq described_class.i32 }
    end

    context "byte is 0x7E" do
      let(:byte) { 0x7E }
      it { is_expected.to eq described_class.i64 }
    end

    context "byte is 0x7D" do
      let(:byte) { 0x7D }
      it { is_expected.to eq described_class.f32 }
    end

    context "byte is 0x7C" do
      let(:byte) { 0x7C }
      it { is_expected.to eq described_class.f64 }
    end

    context "byte is unsupported" do
      let(:byte) { 0x7B }
      it { expect { subject }.to raise_error(WasmMachine::BinaryError, "Invalid value type: 0x7B") }
    end
  end

  describe ".i32" do
    subject { described_class.i32 }

    it { expect(subject.symbol).to be :i32 }
  end

  describe ".i64" do
    subject { described_class.i64}

    it { expect(subject.symbol).to be :i64 }
  end

  describe ".f32" do
    subject { described_class.f32}

    it { expect(subject.symbol).to be :f32 }
  end

  describe ".f64" do
    subject { described_class.f64}

    it { expect(subject.symbol).to be :f64 }
  end

  describe "#==" do
    subject { value_type == other_hand }

    let(:value_type) { described_class.new(:i32) }

    context "other hand is same value type" do
      let(:other_hand) { described_class.new(:i32) }

      it { is_expected.to eq true }
    end

    context "other hand is not same value type" do
      let(:other_hand) { described_class.new(:i64) }

      it { is_expected.to eq false }
    end

    context "other hand is not same class" do
      let(:other_hand) { "foo" }

      it { is_expected.to eq false }
    end
  end
end
