defmodule Docker.Integration.StreamTest do
  use ExUnit.Case, async: false

  @moduletag :integration

  alias Docker.Commands.{Logs, Rm, Run}

  @image "alpine:latest"

  setup_all do
    {:ok, _} = Docker.pull(@image)
    :ok
  end

  setup do
    name = "dw_test_stream_#{:rand.uniform(100_000)}"
    {:ok, name: name}
  end

  test "streams log output from a container", %{name: name} do
    # Start a container that writes output
    {:ok, _} =
      @image
      |> Run.new()
      |> Run.name(name)
      |> Run.detach()
      |> Run.command(["sh", "-c", "for i in 1 2 3; do echo line_$i; sleep 0.2; done"])
      |> Docker.run()

    # Give it a moment to produce output
    Process.sleep(500)

    # Stream the logs
    log_cmd = Logs.new(name) |> Logs.follow()
    {:ok, stream} = Docker.Stream.start_link(log_cmd, subscriber: self())

    lines = collect_lines(stream, [])

    assert length(lines) >= 3
    assert "line_1" in lines
    assert "line_2" in lines
    assert "line_3" in lines

    Docker.rm(Rm.new(name) |> Rm.force())
  end

  test "receives exit message when stream ends", %{name: name} do
    # Container that exits quickly
    {:ok, _} =
      @image
      |> Run.new()
      |> Run.name(name)
      |> Run.detach()
      |> Run.command(["echo", "done"])
      |> Docker.run()

    Process.sleep(500)

    log_cmd = Logs.new(name) |> Logs.follow()
    {:ok, stream} = Docker.Stream.start_link(log_cmd, subscriber: self())

    assert_receive {:docker_stream, ^stream, {:exit, _code}}, 5_000

    Docker.rm(Rm.new(name) |> Rm.force())
  end

  test "stop/1 terminates the stream", %{name: name} do
    {:ok, _} =
      @image
      |> Run.new()
      |> Run.name(name)
      |> Run.detach()
      |> Run.command(["sleep", "300"])
      |> Docker.run()

    log_cmd = Logs.new(name) |> Logs.follow()
    {:ok, stream} = Docker.Stream.start_link(log_cmd, subscriber: self())

    assert Process.alive?(stream)
    Docker.Stream.stop(stream)
    Process.sleep(100)
    refute Process.alive?(stream)

    {:ok, _} = Docker.stop(name)
    Docker.rm(Rm.new(name) |> Rm.force())
  end

  # Collect stdout lines until exit or timeout
  defp collect_lines(stream, acc) do
    receive do
      {:docker_stream, ^stream, {:stdout, line}} ->
        collect_lines(stream, [String.trim(line) | acc])

      {:docker_stream, ^stream, {:exit, _code}} ->
        Enum.reverse(acc)
    after
      5_000 ->
        Enum.reverse(acc)
    end
  end
end
