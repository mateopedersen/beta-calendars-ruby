# frozen_string_literal: true

module BetaCalendars
  module Serializable
    def to_json(*arguments)
      JSON.generate(to_h, *arguments)
    end
  end
end
