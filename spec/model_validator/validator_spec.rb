# frozen_string_literal: true

class NothingHandler # rubocop:disable Lint/EmptyClass
end

RSpec.describe ModelValidator::Validator do
  describe "#classes_to_validate" do
    subject { ModelValidator::Validator.new.classes_to_validate }

    it "returns classes which extends ApplicationRecord" do
      is_expected.to include(DummyModel).once
    end

    it "does not return abstract classes" do
      is_expected.not_to include(ApplicationRecord)
    end

    context "when single table inheritance" do
      it "does not return parent classes" do
        is_expected.not_to include(ParentClass)
      end
      it "returns child classes" do
        is_expected.to include(ChildClass1, ChildClass2)
      end
    end

    context "when ApplicationRecord is not defined" do
      before { hide_const("ApplicationRecord") }
      it { expect { subject }.to raise_error(ModelValidator::ApplicationRecordNotFound) }
    end

    context "when rails env" do
      let(:rails) { double("Rails") }
      let(:rails_app) { double("Rails.application").as_null_object }
      let(:rails_env) { double("Rails.env") }
      before do
        stub_const("Rails", rails)
        allow(rails).to receive(:application) { rails_app }
        allow(rails).to receive(:env) { rails_env }
      end

      context "is development" do
        before do
          allow(rails_env).to receive(:development?) { true }
          subject
        end
        it { expect(Rails.application).to have_received(:eager_load!) }
      end

      context "is not development" do
        before do
          allow(rails_env).to receive(:development?) { false }
          subject
        end
        it { expect(Rails.application).not_to have_received(:eager_load!) }
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
