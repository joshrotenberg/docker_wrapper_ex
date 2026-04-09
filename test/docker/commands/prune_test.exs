defmodule Docker.Commands.PruneTest do
  use ExUnit.Case

  alias Docker.Commands.{ContainerPrune, ImagePrune}

  describe "ContainerPrune" do
    test "default args" do
      assert ContainerPrune.args(ContainerPrune.new()) == ["container", "prune", "-f"]
    end

    test "with filter" do
      args =
        ContainerPrune.new()
        |> ContainerPrune.filter("until=24h")
        |> ContainerPrune.args()

      assert "--filter" in args
      assert "until=24h" in args
    end
  end

  describe "ImagePrune" do
    test "default args" do
      assert ImagePrune.args(ImagePrune.new()) == ["image", "prune", "-f"]
    end

    test "with all" do
      args = ImagePrune.new() |> ImagePrune.all() |> ImagePrune.args()
      assert "-a" in args
    end

    test "with filter" do
      args =
        ImagePrune.new()
        |> ImagePrune.filter("until=24h")
        |> ImagePrune.args()

      assert "--filter" in args
      assert "until=24h" in args
    end
  end
end
