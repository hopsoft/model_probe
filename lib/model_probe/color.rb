# frozen_string_literal: true

module ModelProbe
  module Color
    extend self

    COLORS = {
      blue: 34,
      cyan: 36,
      gray: "1;30",
      green: 32,
      green_light: 92,
      magenta: 35,
      magenta_light: 95,
      pink: "1;91",
      red: 31,
      red_light: 91,
      white: 37,
      yellow: 33,
      yellow_light: 93
    }

    COLORS.each do |name, code|
      define_method name do |text|
        "\e[#{code}m#{text}\e[0m"
      end
    end
  end
end
