# frozen_string_literal: true

class AddPreviousPriceToListings < ActiveRecord::Migration[8.1]
  def change
    add_column :listings, :previous_price, :decimal, precision: 10, scale: 2
  end
end
