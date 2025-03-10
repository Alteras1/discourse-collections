# frozen_string_literal: true

module ::Collections
  module Initializers
    class AddExtensions < Initializer
      def apply
        Guardian.prepend Collections::GuardianExtensions
      end
    end
  end
end