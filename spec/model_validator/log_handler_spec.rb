# frozen_string_literal: true

require "./lib/model_validator"

RSpec.describe ModelValidator::LogHandler do
  let(:log_handler) { ModelValidator::LogHandler.new }

  describe "#on_new_class" do
    context "when 3 models in database" do
      before do
        create_list :dummy_model, 3
        log_handler.on_new_class(DummyModel)
      end
      it { expect(Rails.logger).to have_received(:info).with("Checking 3 DummyModel…") }
    end
  end
end
