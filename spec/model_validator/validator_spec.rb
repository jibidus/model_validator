# frozen_string_literal: true

class NothingHandler # rubocop:disable Lint/EmptyClass
end

RSpec.describe ModelValidator::Validator do
  describe "#classes_to_validate" do
    subject { ModelValidator::Validator.new.classes_to_validate }

    it "returns classes which extends ActiveRecord::Base" do
      is_expected.to include(DummyModel).once
    end

    it "does not return abstract classes" do
      is_expected.not_to include(ApplicationRecord)
    end

    it "returns classes which extends ApplicationRecord" do
      is_expected.to include(Model).once
    end

    context "when single table inheritance" do
      it "does not return parent classes" do
        is_expected.not_to include(ParentClass)
      end
      it "returns child classes" do
        is_expected.to include(ChildClass1, ChildClass2)
      end
    end
  end

  describe "#run" do
    context "with custom handler which does not implement any method" do
      let(:handler) { NothingHandler.new }
      let(:validator) { ModelValidator::Validator.new(handlers: [handler]) }
      it { expect { validator.run }.not_to raise_error }
    end

    context "with many custom handlers" do
      let(:handlers) { [double("handler1").as_null_object, double("handler2").as_null_object] }
      let(:validator) { ModelValidator::Validator.new(handlers: handlers) }
      let!(:valid_model) { create :dummy_model }
      let!(:invalid_model) { build(:dummy_model, value: nil) }

      before { invalid_model.save!(validate: false) }
      it "calls all handlers" do
        handlers.each do |handler|
          expect(handler).to receive(:on_new_class).with(DummyModel)
          expect(handler).to receive(:on_violation).with(invalid_model)
          expect(handler).to receive(:after_validation).with(valid_model)
          expect(handler).to receive(:after_validation).with(invalid_model)
        end
        validator.run
      end
    end
  end
end
