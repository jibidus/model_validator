# frozen_string_literal: true

require "active_record"
require File.join(__dir__, "..", "lib", "model_validator.rb")

class DummyModel < ActiveRecord::Base
  validates :value, presence: true
end

RSpec.describe ModelValidator do
  before(:all) do
    Database.connect
    Database.exec "DROP TABLE IF EXISTS dummy_models"
  end

  before do
    Database.exec "CREATE TABLE IF NOT EXISTS dummy_models (id integer PRIMARY KEY AUTOINCREMENT, value TEXT)"
    Database.exec "DELETE FROM dummy_models"
    allow(Rails.logger).to receive(:info)
    allow(Rails.logger).to receive(:error)
  end

  describe ModelValidator::VERSION do
    it { is_expected.not_to be nil }
  end

  describe "validate_all" do
    subject { ModelValidator.validate_all }

    context "when one violation" do
      before do
        Database.exec "INSERT INTO dummy_models (id, value) VALUES (1, NULL)"
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
        Database.exec "INSERT INTO dummy_models (value) VALUES ('not null')"
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
          Database.exec "INSERT INTO dummy_models (id, value) VALUES (1, NULL)"
          subject
        end

        it { is_expected.to have_no_violation }
        it { is_expected.to have_total(0) }
        it { expect(Rails.logger).to have_received(:info).with("Skipped model(s): DummyModel") }
        it { expect(Rails.logger).not_to have_received(:error) }
      end
    end
  end

  describe ModelValidator::LogHandler do
    describe "on_new_class" do
      before { ModelValidator::LogHandler.new.on_new_class(DummyModel) }
      it { expect(Rails.logger).to have_received(:info).with("Checking DummyModel…") }
    end
  end
end
