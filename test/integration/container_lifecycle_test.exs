defmodule Docker.Integration.ContainerLifecycleTest do
  use ExUnit.Case, async: false

  @moduletag :integration

  alias Docker.Commands.{Create, Exec, Run}

  @image "alpine:latest"

  setup_all do
    # Pull the test image once for all tests
    {:ok, _} = Docker.pull(@image)
    :ok
  end

  setup do
    name = "dw_test_#{:rand.uniform(100_000)}"
    {:ok, name: name}
  end

  describe "run/stop/rm round-trip" do
    test "runs a detached container and cleans up", %{name: name} do
      # Run
      {:ok, cid} =
        @image
        |> Run.new()
        |> Run.name(name)
        |> Run.detach()
        |> Run.command(["sleep", "300"])
        |> Docker.run()

      assert %Docker.ContainerId{} = cid
      assert String.length(cid.full) > 0

      # Verify it shows up in ps
      {:ok, containers} = Docker.ps(all: true)
      assert Enum.any?(containers, fn c -> c["Names"] =~ name end)

      # Exec into it
      {:ok, output} =
        Exec.new(name, ["echo", "hello"])
        |> Docker.exec_cmd()

      assert String.trim(output) == "hello"

      # Logs
      {:ok, _logs} = Docker.logs(name)

      # Stop
      {:ok, _} = Docker.stop(name)

      # Remove
      {:ok, _} = Docker.rm(name)

      # Verify it's gone
      {:ok, containers} = Docker.ps(all: true)
      refute Enum.any?(containers, fn c -> c["Names"] =~ name end)
    end
  end

  describe "create/start/stop" do
    test "creates without starting, then starts", %{name: name} do
      {:ok, cid} =
        @image
        |> Create.new()
        |> Create.name(name)
        |> Create.command(["sleep", "300"])
        |> Docker.create()

      assert %Docker.ContainerId{} = cid

      # Should exist but not be running
      {:ok, containers} = Docker.ps()
      refute Enum.any?(containers, fn c -> c["Names"] =~ name end)

      {:ok, containers} = Docker.ps(all: true)
      assert Enum.any?(containers, fn c -> c["Names"] =~ name end)

      # Start it
      {:ok, _} = Docker.start(name)

      {:ok, containers} = Docker.ps()
      assert Enum.any?(containers, fn c -> c["Names"] =~ name end)

      # Cleanup
      {:ok, _} = Docker.stop(name)
      {:ok, _} = Docker.rm(name)
    end
  end

  describe "pause/unpause" do
    test "pauses and unpauses a running container", %{name: name} do
      {:ok, _} =
        @image
        |> Run.new()
        |> Run.name(name)
        |> Run.detach()
        |> Run.command(["sleep", "300"])
        |> Docker.run()

      {:ok, _} = Docker.pause(name)

      {:ok, [info]} = Docker.inspect_cmd(name)
      assert info["State"]["Paused"] == true

      {:ok, _} = Docker.unpause(name)

      {:ok, [info]} = Docker.inspect_cmd(name)
      assert info["State"]["Paused"] == false

      {:ok, _} = Docker.stop(name)
      {:ok, _} = Docker.rm(name)
    end
  end

  describe "kill" do
    test "kills a running container", %{name: name} do
      {:ok, _} =
        @image
        |> Run.new()
        |> Run.name(name)
        |> Run.detach()
        |> Run.command(["sleep", "300"])
        |> Docker.run()

      {:ok, _} = Docker.kill(name)
      {:ok, _} = Docker.rm(name)
    end
  end

  describe "restart" do
    test "restarts a running container", %{name: name} do
      {:ok, _} =
        @image
        |> Run.new()
        |> Run.name(name)
        |> Run.detach()
        |> Run.command(["sleep", "300"])
        |> Docker.run()

      {:ok, [info_before]} = Docker.inspect_cmd(name)

      {:ok, _} = Docker.restart(name)

      {:ok, [info_after]} = Docker.inspect_cmd(name)
      assert info_after["State"]["StartedAt"] != info_before["State"]["StartedAt"]

      {:ok, _} = Docker.stop(name)
      {:ok, _} = Docker.rm(name)
    end
  end

  describe "inspect" do
    test "returns parsed JSON for a container", %{name: name} do
      {:ok, _} =
        @image
        |> Run.new()
        |> Run.name(name)
        |> Run.detach()
        |> Run.env("TEST_VAR", "hello")
        |> Run.command(["sleep", "300"])
        |> Docker.run()

      {:ok, [info]} = Docker.inspect_cmd(name)
      assert info["Name"] == "/#{name}"
      assert is_map(info["Config"])
      assert "TEST_VAR=hello" in info["Config"]["Env"]

      {:ok, _} = Docker.stop(name)
      {:ok, _} = Docker.rm(name)
    end
  end
end
