# frozen_string_literal: true

# Base ActiveRecord model class.
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
