# frozen_string_literal: true

require "active_record"
require File.join(__dir__, "..", "lib", "model_validator.rb")

RSpec.describe ModelValidator do
  describe ModelValidator::VERSION do
    it { is_expected.not_to be nil }
  end

  describe "validate_all" do
    subject { ModelValidator.validate_all }

    context "when one violation" do
      before do
        build(:dummy_model, id: 1, value: nil).save!(validate: false)
        subject
      end

      it { is_expected.to have_violations(1) }
      it { is_expected.to have_total(1) }
      it { expect(Rails.logger).to have_received(:info).with("No model skipped") }
      it {
        expect(Rails.logger).to have_received(:error)
          .with('#<DummyModel id: 1, errors: ["Value can\'t be blank"]>')
          .once
      }
    end

    context "when no violation" do
      before do
        create :dummy_model
        subject
      end
      it { is_expected.to have_no_violation }
      it { is_expected.to have_total(1) }
      it { expect(Rails.logger).not_to have_received(:error) }
    end

    context "when one model is skipped" do
      subject { ModelValidator.validate_all(skipped_models: [DummyModel]) }

      context "and there is a violation on this model" do
        before do
          build(:dummy_model, :invalid).save!(validate: false)
          subject
        end

        it { is_expected.to have_no_violation }
        it { is_expected.to have_total(0) }
        it { expect(Rails.logger).to have_received(:info).with("Skipped model(s): DummyModel") }
        it { expect(Rails.logger).not_to have_received(:error) }
      end
    end
  end
end
