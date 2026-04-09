defmodule Docker.Integration.NetworkVolumeTest do
  use ExUnit.Case, async: false

  @moduletag :integration

  alias Docker.Commands.{Network, Run}

  describe "network lifecycle" do
    setup do
      name = "dw_test_net_#{:rand.uniform(100_000)}"
      {:ok, name: name}
    end

    test "create/ls/inspect/rm", %{name: name} do
      {:ok, _} = Docker.network_create(name)

      {:ok, networks} = Docker.network_ls()
      assert Enum.any?(networks, fn n -> n["Name"] == name end)

      {:ok, [info]} = Docker.network_inspect(name)
      assert info["Name"] == name

      {:ok, _} = Docker.network_rm(name)

      {:ok, networks} = Docker.network_ls()
      refute Enum.any?(networks, fn n -> n["Name"] == name end)
    end

    test "connect/disconnect a container", %{name: name} do
      container = "dw_test_netc_#{:rand.uniform(100_000)}"

      {:ok, _} = Docker.network_create(name)

      {:ok, _} =
        Run.new("alpine:latest")
        |> Run.name(container)
        |> Run.detach()
        |> Run.command(["sleep", "300"])
        |> Docker.run()

      {:ok, :done} =
        Docker.network_connect(Network.Connect.new(name, container))

      {:ok, [info]} = Docker.network_inspect(name)
      assert map_size(info["Containers"]) == 1

      {:ok, :done} =
        Docker.network_disconnect(Network.Disconnect.new(name, container))

      {:ok, [info]} = Docker.network_inspect(name)
      assert map_size(info["Containers"]) == 0

      {:ok, _} = Docker.stop(container)
      {:ok, _} = Docker.rm(container)
      {:ok, _} = Docker.network_rm(name)
    end
  end

  describe "volume lifecycle" do
    setup do
      name = "dw_test_vol_#{:rand.uniform(100_000)}"
      {:ok, name: name}
    end

    test "create/ls/inspect/rm", %{name: name} do
      {:ok, _} = Docker.volume_create(name)

      {:ok, volumes} = Docker.volume_ls()
      assert Enum.any?(volumes, fn v -> v["Name"] == name end)

      {:ok, [info]} = Docker.volume_inspect(name)
      assert info["Name"] == name

      {:ok, _} = Docker.volume_rm(name)

      {:ok, volumes} = Docker.volume_ls()
      refute Enum.any?(volumes, fn v -> v["Name"] == name end)
    end
  end
end
