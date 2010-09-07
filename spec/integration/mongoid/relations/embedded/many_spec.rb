require "spec_helper"

describe Mongoid::Relations::Embedded::Many do

  [ :<<, :push, :concat ].each do |method|

    describe "#{method}" do

      context "when the parent is a new record" do

        let(:person) do
          Person.new
        end

        let(:address) do
          Address.new
        end

        before do
          person.addresses.send(method, address)
        end

        it "appends to the target" do
          person.addresses.should == [ address ]
        end

        it "sets the base on the inverse relation" do
          address.addressable.should == person
        end

        it "does not save the new document" do
          address.should_not be_persisted
        end

        it "sets the parent on the child" do
          address._parent.should == person
        end

        it "sets the metadata on the child" do
          address.metadata.should_not be_nil
        end

        it "sets the index on the child" do
          address._index.should == 0
        end
      end

      context "when the parent is not a new record" do

        let(:person) do
          Person.create(:ssn => "234-44-4432")
        end

        let(:address) do
          Address.new
        end

        before do
          person.addresses.send(method, address)
        end

        it "saves the new document" do
          address.should be_persisted
        end
      end
    end
  end

  describe "#=" do

    context "when the parent is a new record" do

      let(:person) do
        Person.new
      end

      let(:address) do
        Address.new
      end

      before do
        person.addresses = [ address ]
      end

      it "sets the target of the relation" do
        person.addresses.should == [ address ]
      end

      it "sets the base on the inverse relation" do
        address.addressable.should == person
      end

      it "does not save the target" do
        address.should_not be_persisted
      end

      it "sets the parent on the child" do
        address._parent.should == person
      end

      it "sets the metadata on the child" do
        address.metadata.should_not be_nil
      end

      it "sets the index on the child" do
        address._index.should == 0
      end
    end

    context "when the parent is not a new record" do

      let(:person) do
        Person.create(:ssn => "999-98-9988")
      end

      let(:address) do
        Address.new
      end

      before do
        person.addresses = [ address ]
      end

      it "saves the target" do
        address.should be_persisted
      end
    end
  end

  describe "#= nil" do

    context "when the parent is a new record" do

      let(:person) do
        Person.new
      end

      let(:address) do
        Address.new
      end

      before do
        person.addresses = [ address ]
        person.addresses = nil
      end

      it "sets the relation to empty" do
        person.addresses.should be_empty
      end

      it "removes the inverse relation" do
        address.addressable.should be_nil
      end
    end

    context "when the inverse is already nil" do

      let(:person) do
        Person.new
      end

      before do
        person.addresses = nil
      end

      it "sets the relation to empty" do
        person.addresses.should be_empty
      end
    end

    context "when the documents are not new records" do

      let(:person) do
        Person.create(:ssn => "437-11-1112")
      end

      let(:address) do
        Address.new
      end

      before do
        person.addresses = [ address ]
        person.addresses = nil
      end

      it "sets the relation to empty" do
        person.addresses.should be_empty
      end

      it "removed the inverse relation" do
        address.addressable.should be_nil
      end

      it "deletes the child document" do
        address.should be_destroyed
      end
    end
  end
end
