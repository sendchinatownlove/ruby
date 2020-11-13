class AddProjectToPaymentIntent < ActiveRecord::Migration[6.0]
  def change
    add_reference :payment_intents, :project, null: true, foreign_key: true
  end
end
