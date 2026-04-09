defmodule Docker.Commands.VolumeTest do
  use ExUnit.Case

  alias Docker.Commands.Volume

  describe "Volume.Create" do
    test "anonymous volume" do
      assert Volume.Create.args(Volume.Create.new()) == ["volume", "create"]
    end

    test "named volume" do
      assert Volume.Create.args(Volume.Create.new("my-vol")) ==
               ["volume", "create", "my-vol"]
    end

    test "with driver and labels" do
      args =
        "my-vol"
        |> Volume.Create.new()
        |> Volume.Create.driver("local")
        |> Volume.Create.label("env", "test")
        |> Volume.Create.opt("type", "nfs")
        |> Volume.Create.args()

      assert "--driver" in args
      assert "local" in args
      assert "--label" in args
      assert "env=test" in args
      assert "-o" in args
      assert "type=nfs" in args
    end
  end

  describe "Volume.Rm" do
    test "single volume" do
      assert Volume.Rm.args(Volume.Rm.new("my-vol")) == ["volume", "rm", "my-vol"]
    end

    test "multiple with force" do
      args = Volume.Rm.new(["vol1", "vol2"]) |> Volume.Rm.force() |> Volume.Rm.args()
      assert args == ["volume", "rm", "-f", "vol1", "vol2"]
    end
  end

  describe "Volume.Ls" do
    test "default args" do
      assert Volume.Ls.args(Volume.Ls.new()) == ["volume", "ls", "--format", "json"]
    end

    test "with quiet and filter" do
      args =
        Volume.Ls.new()
        |> Volume.Ls.quiet()
        |> Volume.Ls.filter("dangling=true")
        |> Volume.Ls.args()

      assert "-q" in args
      assert "--filter" in args
      assert "dangling=true" in args
    end

    test "parse_output" do
      json =
        ~s({"Name":"my-vol","Driver":"local","Mountpoint":"/var/lib/docker/volumes/my-vol"}\n)

      {:ok, volumes} = Volume.Ls.parse_output(json, 0)
      assert hd(volumes)["Name"] == "my-vol"
    end
  end

  describe "Volume.Inspect" do
    test "single volume" do
      assert Volume.Inspect.args(Volume.Inspect.new("my-vol")) ==
               ["volume", "inspect", "my-vol"]
    end

    test "with format" do
      args =
        Volume.Inspect.new("my-vol") |> Volume.Inspect.format("json") |> Volume.Inspect.args()

      assert "--format" in args
      assert "json" in args
    end

    test "parse_output" do
      json = ~s([{"Name":"my-vol","Driver":"local"}])
      {:ok, data} = Volume.Inspect.parse_output(json, 0)
      assert hd(data)["Name"] == "my-vol"
    end
  end

  describe "Volume.Prune" do
    test "default args" do
      assert Volume.Prune.args(Volume.Prune.new()) == ["volume", "prune", "-f"]
    end

    test "with all" do
      args = Volume.Prune.new() |> Volume.Prune.all() |> Volume.Prune.args()
      assert "-a" in args
    end

    test "with filter" do
      args = Volume.Prune.new() |> Volume.Prune.filter("label=test") |> Volume.Prune.args()
      assert "--filter" in args
      assert "label=test" in args
    end
  end
end
