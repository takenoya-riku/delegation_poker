module Service
  extend ActiveSupport::Concern

  included do
    def self.call(**kwargs)
      new.call(**kwargs)
    end
  end

  delegate :logger, to: :Rails
end
