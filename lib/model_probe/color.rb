module ModelProbe
  module Color
    extend self

    colors = {
      :red     => 31,
      :green   => 32,
      :yellow  => 33,
      :blue    => 34,
      :magenta => 35,
      :cyan    => 36,
      :white   => 37
    }

    colors.each do |name, code|
      define_method name do |text|
      "\e[#{code}m#{text}\e[0m"
      end
    end
  end
end
