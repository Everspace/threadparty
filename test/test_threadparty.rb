require_relative 'helper'

RSpec.describe ThreadParty, '#init' do
  context "regardless on how you call it" do
    number_work = Proc.new {|i| sleep((i % 4) * 0.01); i * 2}
    string_work = Proc.new {|s| s}
    partyA = ThreadParty.new()
    partyA.add do
      ProcessQueue do
        queue 0..20
        perform &number_work
      end
    end

    partyA.add do
      ProcessQueue do
        queue 'A'..'Q'
        perform &string_work
      end
    end

    partyB = ThreadParty.new()
    partyB.add do
      ProcessQueue do
        queue 0..20
        perform &number_work
      end
      ProcessQueue do
        queue 'A'..'Q'
        perform &string_work
      end
    end

    pAs = partyA.sequentially.group_by{|i| i.class}
    pAi = partyA.iteratively.group_by{|i| i.class}

    pBs = partyB.sequentially.group_by{|i| i.class}
    pBi = partyB.iteratively.group_by{|i| i.class}

    pCs = ThreadParty.new{
      ProcessQueue do
        queue 0..20
        perform &number_work
      end
      ProcessQueue do
        queue 'A'..'Q'
        perform &string_work
      end
    }.sequentially.group_by{|i| i.class}

    pCi = ThreadParty.new{
      ProcessQueue do
        queue 0..20
        perform &number_work
      end
      ProcessQueue do
        queue 'A'..'Q'
        perform &string_work
      end
    }.iteratively.group_by{|i| i.class}


    it "the results are the same when sorted" do
      expect(pAs[Fixnum].sort).to eq pBs[Fixnum].sort
      expect(pAs[Fixnum].sort).to eq pCs[Fixnum].sort
      expect(pAi[Fixnum].sort).to eq pBi[Fixnum].sort
      expect(pAi[Fixnum].sort).to eq pCi[Fixnum].sort
    end
  end
end
