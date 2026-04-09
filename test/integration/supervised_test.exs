defmodule Docker.Integration.SupervisedTest do
  use ExUnit.Case, async: false

  @moduletag :integration

  alias Docker.Commands.{Rm, Run}
  alias Docker.Supervised

  @image "alpine:latest"

  setup_all do
    {:ok, _} = Docker.pull(@image)
    :ok
  end

  setup do
    name = "dw_test_sup_#{:rand.uniform(100_000)}"
    {:ok, name: name}
  end

  test "start, query, and stop a supervised container", %{name: name} do
    run_cmd =
      @image
      |> Run.new()
      |> Run.name(name)
      |> Run.command(["sleep", "300"])

    {:ok, pid} = Supervised.start_link(run_cmd, health_check: false)

    # Should have a container ID
    container_id = Supervised.container_id(pid)
    assert is_binary(container_id)
    assert String.length(container_id) > 0

    # Status should be running
    assert Supervised.status(pid) == :running

    # Verify the container actually exists
    {:ok, [info]} = Docker.inspect_cmd(container_id)
    assert info["State"]["Running"] == true

    # Stop it
    :ok = Supervised.stop_container(pid)
    assert Supervised.status(pid) == :stopped

    # Cleanup
    Docker.rm(Rm.new(name) |> Rm.force())
  end

  test "health check transitions to healthy", %{name: name} do
    run_cmd =
      @image
      |> Run.new()
      |> Run.name(name)
      |> Run.command(["sleep", "300"])

    {:ok, pid} = Supervised.start_link(run_cmd, health_interval: 500, health_check: true)

    # Initial state is :starting
    assert Supervised.healthy?(pid) == :starting

    # Wait for health check to run
    Process.sleep(1_000)

    # Should be healthy (alpine with sleep has no HEALTHCHECK, so inspect
    # returns running without a Health key, which maps to :healthy)
    assert Supervised.healthy?(pid) == :healthy

    :ok = Supervised.stop_container(pid)
    Docker.rm(Rm.new(name) |> Rm.force())
  end

  test "terminate cleans up the container", %{name: name} do
    run_cmd =
      @image
      |> Run.new()
      |> Run.name(name)
      |> Run.command(["sleep", "300"])

    {:ok, pid} = Supervised.start_link(run_cmd, health_check: false)
    container_id = Supervised.container_id(pid)

    # Verify running
    {:ok, [info]} = Docker.inspect_cmd(container_id)
    assert info["State"]["Running"] == true

    # Stop the GenServer (triggers terminate)
    GenServer.stop(pid)

    # Container should be stopped
    {:ok, [info]} = Docker.inspect_cmd(container_id)
    assert info["State"]["Running"] == false

    Docker.rm(Rm.new(name) |> Rm.force())
  end

  test "rm_on_terminate removes the container", %{name: name} do
    run_cmd =
      @image
      |> Run.new()
      |> Run.name(name)
      |> Run.command(["sleep", "300"])

    {:ok, pid} = Supervised.start_link(run_cmd, health_check: false, rm_on_terminate: true)
    _container_id = Supervised.container_id(pid)

    GenServer.stop(pid)

    # Container should be gone
    Process.sleep(200)
    {:ok, containers} = Docker.ps(all: true)
    refute Enum.any?(containers, fn c -> c["Names"] =~ name end)
  end

  test "works under a Supervisor", %{name: name} do
    run_cmd =
      @image
      |> Run.new()
      |> Run.name(name)
      |> Run.command(["sleep", "300"])

    children = [
      {Supervised, {run_cmd, name: :"dw_#{name}", health_check: false}}
    ]

    {:ok, sup} = Supervisor.start_link(children, strategy: :one_for_one)

    # Query via registered name
    assert is_binary(Supervised.container_id(:"dw_#{name}"))
    assert Supervised.status(:"dw_#{name}") == :running

    Supervisor.stop(sup)
    Process.sleep(200)
    Docker.rm(Rm.new(name) |> Rm.force())
  end
end
