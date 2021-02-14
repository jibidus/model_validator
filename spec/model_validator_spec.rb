# frozen_string_literal: true

require "active_record"
require File.join(__dir__, "..", "lib", "model_validator.rb")

class DummyModel < ActiveRecord::Base
  validates :value, presence: true
end

RSpec.describe ModelValidator do
  before(:all) do
    @db = Database.new
    @db.connect
    @db.exec "DROP TABLE IF EXISTS dummy_models"
  end

  before do
    @db.exec "CREATE TABLE IF NOT EXISTS dummy_models (id integer PRIMARY KEY AUTOINCREMENT, value TEXT)"
    @db.exec "DELETE FROM dummy_models"
    allow(Rails.logger).to receive(:info)
    allow(Rails.logger).to receive(:error)
  end

  describe ModelValidator::VERSION do
    it { is_expected.not_to be nil }
  end

  describe "validate_all" do
    context "when one violation" do
      before do
        @db.exec "INSERT INTO dummy_models (id, value) VALUES (1, NULL)"
        ModelValidator.validate_all
      end
      it { expect(Rails.logger).to have_received(:info).with("No model skipped") }
      it {
        expect(Rails.logger).to have_received(:error)
          .with('#<DummyModel id: 1, errors: ["Value can\'t be blank"]>')
          .once
      }
    end

    context "when one violation on skipped model" do
      before do
        @db.exec "INSERT INTO dummy_models (id, value) VALUES (1, NULL)"
        ModelValidator.validate_all skipped_models: [DummyModel]
      end

      it { expect(Rails.logger).to have_received(:info).with("Skipped model(s): DummyModel") }
      it { expect(Rails.logger).not_to have_received(:error) }
    end

    context "when no violation" do
      before do
        @db.exec "INSERT INTO dummy_models (value) VALUES ('not null')"
        ModelValidator.validate_all
      end
      it { expect(Rails.logger).not_to have_received(:error) }
    end
  end
end
