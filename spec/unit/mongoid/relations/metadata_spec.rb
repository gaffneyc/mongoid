require "spec_helper"

describe Mongoid::Relations::Metadata do

  let(:klass) do
    Mongoid::Relations::Metadata
  end

  describe "#builder" do

    let(:metadata) do
      klass.new(:relation => Mongoid::Relations::Embedded::One)
    end

    let(:object) do
      stub
    end

    it "returns the builder from the relation" do
      metadata.builder(object).should
        be_a_kind_of(Mongoid::Relations::Builders::Embedded::One)
    end
  end

  describe "#class_name" do

    context "when class_name provided" do

      let(:metadata) do
        klass.new(:class_name => "Person")
      end

      it "constantizes the class name" do
        metadata.class_name.should == "Person"
      end
    end

    context "when no class_name provided" do

      context "when association name is singular" do

        let(:relation) do
          stub(:macro => :embeds_one)
        end

        let(:metadata) do
          klass.new(:name => :name, :relation => relation)
        end

        it "classifies and constantizes the association name" do
          metadata.class_name.should == "Name"
        end
      end

      context "when association name is plural" do

        let(:relation) do
          stub(:macro => :embeds_many)
        end

        let(:metadata) do
          klass.new(:name => :addresses, :relation => relation)
        end

        it "classifies and constantizes the association name" do
          metadata.class_name.should == "Address"
        end
      end
    end
  end

  describe "#embedded?" do

    context "when the relation is embedded" do

      let(:metadata) do
        klass.new(:relation => relation)
      end

      let(:relation) do
        stub(:macro => :embeds_one)
      end

      it "returns true" do
        metadata.should be_embedded
      end
    end

    context "when the relation is not embedded" do

      let(:metadata) do
        klass.new(:relation => relation)
      end

      let(:relation) do
        stub(:macro => :references_one)
      end

      it "returns false" do
        metadata.should_not be_embedded
      end
    end
  end

  describe "#extension" do

    let(:metadata) do
      klass.new(:extend => :value)
    end

    it "returns the extend property" do
      metadata.extension.should == :value
    end
  end

  describe "#extension?" do

    context "when an extends property exists" do

      let(:metadata) do
        klass.new(:extend => :value)
      end

      it "returns true" do
        metadata.extension?.should == true
      end
    end

    context "when the extend option is nil" do

      let(:metadata) do
        klass.new
      end

      it "returns false" do
        metadata.extension?.should == false
      end
    end
  end

  describe "#foreign_key" do

    context "when no foreign key was explicitly defined" do

      context "when the relation stores a foreign key" do

        context "when referenced in" do

          let(:metadata) do
            klass.new(
              :name => :person,
              :relation => Mongoid::Relations::Referenced::In
            )
          end

          it "returns the foreign_key" do
            metadata.foreign_key.should == "person_id"
          end
        end

        context "when references and referenced in many" do

          let(:metadata) do
            klass.new(
              :name => :people,
              :relation => Mongoid::Relations::Referenced::ManyToMany
            )
          end

          it "returns the foreign_key" do
            metadata.foreign_key.should == "person_ids"
          end
        end

        context "when references many as array" do

          let(:metadata) do
            klass.new(
              :name => :posts,
              :relation => Mongoid::Relations::Referenced::ManyAsArray
            )
          end

          it "returns the foreign_key" do
            metadata.foreign_key.should == "post_ids"
          end
        end
      end

      context "when the relation does not store a foreign key" do

        context "when references one" do

          let(:metadata) do
            klass.new(
              :name => :post,
              :relation => Mongoid::Relations::Referenced::One,
              :inverse_class_name => "Person"
            )
          end

          it "returns the inverse foreign key" do
            metadata.foreign_key.should == "person_id"
          end
        end

        context "when references many" do

          let(:metadata) do
            klass.new(
              :name => :posts,
              :relation => Mongoid::Relations::Referenced::Many,
              :inverse_class_name => "Person"
            )
          end

          it "returns the inverse foreign key" do
            metadata.foreign_key.should == "person_id"
          end
        end

        context "when referenced in from array" do

          let(:metadata) do
            klass.new(
              :name => :person,
              :relation => Mongoid::Relations::Referenced::InFromArray,
              :inverse_class_name => "Post"
            )
          end

          it "returns the inverse foreign key" do
            metadata.foreign_key.should == "post_ids"
          end
        end
      end
    end

    context "when a foreign_key was defined" do

      let(:metadata) do
        klass.new(
          :name => :person,
          :relation => Mongoid::Relations::Referenced::InFromArray,
          :foreign_key => "blog_post_id"
        )
      end

      it "returns the foreign_key" do
        metadata.foreign_key.should == "blog_post_id"
      end
    end
  end

  describe "#foreign_key_setter" do

      let(:metadata) do
        klass.new(
          :name => :person,
          :relation => Mongoid::Relations::Referenced::InFromArray,
          :foreign_key => "person_id"
        )
      end

    it "returns the foreign_key plus =" do
      metadata.foreign_key_setter.should == "person_id="
    end
  end

  describe "#indexed?" do

    context "when an index property exists" do

      let(:metadata) do
        klass.new(:index => true)
      end

      it "returns true" do
        metadata.indexed?.should == true
      end
    end

    context "when the index option is nil" do

      let(:metadata) do
        klass.new
      end

      it "returns false" do
        metadata.index?.should == false
      end
    end

    context "when the index option is false" do

      let(:metadata) do
        klass.new(:index => false)
      end

      it "returns false" do
        metadata.indexed?.should == false
      end
    end
  end

  context "#inverse" do

    context "when an inverse relation exists" do

      context "when not polymorphic" do

        let(:metadata) do
          klass.new(
            :name => :pet,
            :class_name => "Animal",
            :inverse_class_name => "Person"
          )
        end

        it "returns the name of the relation" do
          metadata.inverse.should == :person
        end
      end

      context "when polymorphic" do

        let(:metadata) do
          klass.new(
            :name => :addresses,
            :as => :addressable,
            :inverse_class_name => "Person"
          )
        end

        it "returns the name of the relation" do
          metadata.inverse.should == :addressable
        end
      end

      context "when polymorphic on the child" do

        let(:metadata) do
          klass.new(
            :name => :addressable,
            :polymorphic => true,
            :inverse_class_name => "Address"
          )
        end

        it "returns the name of the relation" do
          metadata.inverse(Person.new).should == :addresses
        end
      end
    end
  end

  context "#inverse_klass" do

    let(:metadata) do
      klass.new(:inverse_class_name => "Person")
    end

    it "constantizes the inverse_class_name" do
      metadata.inverse_klass.should == Person
    end
  end

  context "#inverse_setter" do

    let(:metadata) do
      klass.new(
        :name => :pet,
        :class_name => "Animal",
        :inverse_class_name => "Person"
      )
    end

    it "returns a string for the setter" do
      metadata.inverse_setter.should == "person="
    end
  end

  context "#key" do

    context "when relation is embedded" do

      let(:metadata) do
        klass.new(
          :name => :addresses,
          :relation => Mongoid::Relations::Embedded::Many
        )
      end

      it "returns the name as a string" do
        metadata.key.should == "addresses"
      end
    end

    context "when relation is referenced" do

      context "when relation stores foreign_key" do

        let(:metadata) do
          klass.new(
            :name => :posts,
            :relation => Mongoid::Relations::Referenced::ManyAsArray
          )
        end

        it "returns the foreign_key" do
          metadata.key.should == "post_ids"
        end
      end

      context "when relation does not store a foreign_key" do

        let(:metadata) do
          klass.new(
            :name => :addresses,
            :relation => Mongoid::Relations::Referenced::Many,
            :inverse_class_name => "Person"
          )
        end

        it "returns _id" do
          metadata.key.should == "_id"
        end
      end
    end
  end

  context "#klass" do

    let(:metadata) do
      klass.new(:class_name => "Address")
    end

    it "constantizes the class_name" do
      metadata.klass.should == Address
    end
  end

  context "#macro" do

    let(:metadata) do
      klass.new(:relation => Mongoid::Relations::Embedded::One)
    end

    it "returns the macro from the relation" do
      metadata.macro.should == :embeds_one
    end
  end

  describe "#nested_builder" do

    let(:metadata) do
      klass.new(:relation => Mongoid::Relations::Embedded::One)
    end

    let(:attributes) do
      {}
    end

    let(:options) do
      {}
    end

    it "returns the nested builder from the relation" do
      metadata.nested_builder(attributes, options).should
        be_a_kind_of(Mongoid::Relations::Builders::NestedAttributes::One)
    end
  end

  context "properties" do

    PROPERTIES = [
      "dependent",
      "inverse_class_name",
      "inverse_of",
      "name",
      "polymorphic",
      "relation",
      "stored_as"
    ]

    PROPERTIES.each do |property|

      describe "##{property}" do

        let(:metadata) do
          klass.new(property.to_sym => :value)
        end

        it "returns the #{property} property" do
          metadata.send(property).should == :value
        end
      end

      describe "##{property}?" do

        context "when a #{property} property exists" do

          let(:metadata) do
            klass.new(property.to_sym => :value)
          end

          it "returns true" do
            metadata.send("#{property}?").should == true
          end
        end

        context "when the #{property} property is nil" do

          let(:metadata) do
            klass.new
          end

          it "returns false" do
            metadata.send("#{property}?").should == false
          end
        end
      end
    end
  end
end
