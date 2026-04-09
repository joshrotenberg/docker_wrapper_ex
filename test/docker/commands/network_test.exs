defmodule Docker.Commands.NetworkTest do
  use ExUnit.Case

  alias Docker.Commands.Network

  describe "Network.Create" do
    test "basic create" do
      assert Network.Create.args(Network.Create.new("my-net")) ==
               ["network", "create", "my-net"]
    end

    test "with driver and subnet" do
      args =
        "my-net"
        |> Network.Create.new()
        |> Network.Create.driver("bridge")
        |> Network.Create.subnet("172.20.0.0/16")
        |> Network.Create.gateway("172.20.0.1")
        |> Network.Create.args()

      assert "--driver" in args
      assert "bridge" in args
      assert "--subnet" in args
      assert "172.20.0.0/16" in args
      assert "--gateway" in args
      assert "172.20.0.1" in args
    end

    test "with internal and attachable" do
      args =
        Network.Create.new("my-net")
        |> Network.Create.internal()
        |> Network.Create.attachable()
        |> Network.Create.args()

      assert "--internal" in args
      assert "--attachable" in args
    end

    test "with labels and opts" do
      args =
        Network.Create.new("my-net")
        |> Network.Create.label("env", "test")
        |> Network.Create.opt("com.docker.network.bridge.name", "br0")
        |> Network.Create.args()

      assert "--label" in args
      assert "env=test" in args
      assert "-o" in args
      assert "com.docker.network.bridge.name=br0" in args
    end
  end

  describe "Network.Rm" do
    test "single network" do
      assert Network.Rm.args(Network.Rm.new("my-net")) == ["network", "rm", "my-net"]
    end

    test "multiple with force" do
      args = Network.Rm.new(["net1", "net2"]) |> Network.Rm.force() |> Network.Rm.args()
      assert args == ["network", "rm", "-f", "net1", "net2"]
    end
  end

  describe "Network.Ls" do
    test "default args" do
      assert Network.Ls.args(Network.Ls.new()) == ["network", "ls", "--format", "json"]
    end

    test "with filters" do
      args =
        Network.Ls.new()
        |> Network.Ls.filter("driver=bridge")
        |> Network.Ls.args()

      assert "--filter" in args
      assert "driver=bridge" in args
    end

    test "parse_output" do
      json = ~s({"Name":"bridge","Driver":"bridge","Scope":"local"}\n)
      {:ok, networks} = Network.Ls.parse_output(json, 0)
      assert hd(networks)["Name"] == "bridge"
    end
  end

  describe "Network.Inspect" do
    test "single network" do
      assert Network.Inspect.args(Network.Inspect.new("my-net")) ==
               ["network", "inspect", "my-net"]
    end

    test "parse_output" do
      json = ~s([{"Name":"my-net","Driver":"bridge"}])
      {:ok, data} = Network.Inspect.parse_output(json, 0)
      assert hd(data)["Name"] == "my-net"
    end
  end

  describe "Network.Connect" do
    test "basic connect" do
      args = Network.Connect.args(Network.Connect.new("my-net", "my-container"))
      assert args == ["network", "connect", "my-net", "my-container"]
    end

    test "with ip and aliases" do
      args =
        Network.Connect.new("my-net", "my-container")
        |> Network.Connect.ip("172.20.0.5")
        |> Network.Connect.network_alias("redis")
        |> Network.Connect.args()

      assert "--ip" in args
      assert "172.20.0.5" in args
      assert "--alias" in args
      assert "redis" in args
    end

    test "parse_output" do
      assert Network.Connect.parse_output("", 0) == {:ok, :done}
    end
  end

  describe "Network.Disconnect" do
    test "basic disconnect" do
      args = Network.Disconnect.args(Network.Disconnect.new("my-net", "my-container"))
      assert args == ["network", "disconnect", "my-net", "my-container"]
    end

    test "with force" do
      args =
        Network.Disconnect.new("my-net", "my-container")
        |> Network.Disconnect.force()
        |> Network.Disconnect.args()

      assert "-f" in args
    end
  end

  describe "Network.Prune" do
    test "default args" do
      assert Network.Prune.args(Network.Prune.new()) == ["network", "prune", "-f"]
    end

    test "with filter" do
      args = Network.Prune.new() |> Network.Prune.filter("until=24h") |> Network.Prune.args()
      assert "--filter" in args
      assert "until=24h" in args
    end
  end
end
