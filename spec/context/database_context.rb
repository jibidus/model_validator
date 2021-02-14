shared_context 'database setup' do

  class DummyModel<ApplicationRecord
    validates :value, presence: true
  end

  before do
    ApplicationRecord.connection.execute "CREATE TABLE dummy_model (value text)"
  end
end
