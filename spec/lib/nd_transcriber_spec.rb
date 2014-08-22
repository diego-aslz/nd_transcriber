require 'spec_helper'

Origin = Struct.new(:name, :last_name, :gender)

Dest = Struct.new(:name, :last_name, :complete_name, :male_female, :transcribed,
  :nickname) do
  include NdTranscriber

  transcriber do
    copy_fields :last_name,
      :gender => :male_female,
      :name => [:name, :nickname]
    copy :name, to: :complete_name do |name|
      "#{name} #{origin.last_name}"
    end
    self.transcribed = true
  end
end

Dest2 = Struct.new(:id) do
  include NdTranscriber
  transcribes_to do |origin|
    new(5) if origin
  end
end

describe NdTranscriber do
  let(:origin) { Origin.new('John', 'Doe', 'M') }

  subject { Dest.transcribe(origin) }

  it "copies attributes" do
    expect(subject.name)         .to eq 'John'
    expect(subject.nickname)     .to eq 'John'
    expect(subject.last_name)    .to eq 'Doe'
    expect(subject.complete_name).to eq 'John Doe'
    expect(subject.male_female)  .to eq 'M'
    expect(subject.transcribed)  .to eq true
  end

  it "yields the copied object" do
    expect{ |probe| Dest.transcribe(origin, &probe) }.to yield_with_args(
      kind_of(Dest))
  end

  context "transcribes_to is provided" do
    subject(:dest2) { Dest2.transcribe(origin) }

    it "uses transcribes_to to define where to transcribe" do
      expect(dest2.id).to eq(5)
    end
  end

  describe "copy_all" do
    let(:list) { [Origin.new('John', 'Doe', 'M'),
      Origin.new('Mary', 'Doe', 'F')] }

    subject(:dests) { Dest.transcribe_all(list) }

    it 'copies all of the objects' do
      expect(dests.size    ).to eq 2
      expect(dests[1].name ).to eq 'Mary'
      expect(dests[1].class).to eq Dest
    end

    it "yields each copied object" do
      expect{ |probe| Dest.transcribe_all(list, &probe) }.to yield_successive_args(
        kind_of(Dest), kind_of(Dest))
    end
  end
end
