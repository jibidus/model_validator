# frozen_string_literal: true
require "active_record"
require File.join(__dir__, "..", "lib", "model_validator.rb")

class DummyModel < ActiveRecord::Base
  validates :value, presence: true
end

RSpec.describe ModelValidator do

  before(:all) do
    Database.new.connect
    ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS dummy_models")
  end

  before do
    ActiveRecord::Base.connection.execute "CREATE TABLE IF NOT EXISTS dummy_models (id integer PRIMARY KEY AUTOINCREMENT, value TEXT)"
    ActiveRecord::Base.connection.execute "DELETE FROM dummy_models"
    allow(Rails.logger).to receive(:info)
    allow(Rails.logger).to receive(:error)
  end

  it { expect(ModelValidator::VERSION).not_to be nil }

  describe "validate_all" do

    context "when one violation" do
      before do
        ActiveRecord::Base.connection.execute("INSERT INTO dummy_models (id, value) VALUES (1, NULL)")
        ModelValidator.validate_all
      end
      it { expect(Rails.logger).to have_received(:info).with("No excluded model") }
      it { expect(Rails.logger).to have_received(:error).with('#<DummyModel id: 1, errors: ["Value can\'t be blank"]>').once }
    end

    context "when one violation on excluded model" do
      before do
        ActiveRecord::Base.connection.execute("INSERT INTO dummy_models (id, value) VALUES (1, NULL)")
        ModelValidator.validate_all excluded_models: [DummyModel]
      end

      it { expect(Rails.logger).to have_received(:info).with("Excluded model(s): DummyModel") }
      it { expect(Rails.logger).not_to have_received(:error) }
    end

    context "when no violation" do
      before do
        ActiveRecord::Base.connection.execute("INSERT INTO dummy_models (value) VALUES ('not null')")
        ModelValidator.validate_all
      end
      it { expect(Rails.logger).not_to have_received(:error) }
    end
  end
end
