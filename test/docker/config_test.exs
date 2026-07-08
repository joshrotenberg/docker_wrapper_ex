defmodule Docker.ConfigTest do
  use ExUnit.Case, async: true

  doctest Docker.Config

  alias Docker.Config

  describe "runner option" do
    test "defaults to :system" do
      config = Config.new(binary: "/usr/bin/docker")
      assert config.runner == :system
    end

    test "can be set to :forcola" do
      config = Config.new(binary: "/usr/bin/docker", runner: :forcola)
      assert config.runner == :forcola
    end
  end
end
