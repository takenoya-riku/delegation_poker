require 'ostruct'

module Service
  extend ActiveSupport::Concern

  included do
    def self.call(**kwargs)
      new.call(**kwargs)
    end
  end

  def logger
    Rails.logger
  end
end
