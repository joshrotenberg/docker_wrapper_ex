defmodule Docker.Integration.StreamCallbackTest do
  use ExUnit.Case, async: false

  @moduletag :integration

  alias Docker.Commands.{Rm, Run}

  @image "alpine:latest"

  setup_all do
    {:ok, _} = Docker.pull(@image)
    :ok
  end

  test "pull with stream callback receives progress lines" do
    lines = :ets.new(:pull_lines, [:bag, :public])

    {:ok, _} =
      Docker.pull(@image, stream: fn line -> :ets.insert(lines, {:line, line}) end)

    collected = :ets.lookup(lines, :line) |> Enum.map(fn {:line, l} -> l end)
    :ets.delete(lines)

    # Pull of an already-cached image still outputs status lines
    assert collected != []
  end

  test "run with stream callback captures output" do
    lines = :ets.new(:run_lines, [:bag, :public])

    name = "dw_test_sc_#{:rand.uniform(100_000)}"

    cmd =
      Run.new(@image)
      |> Run.name(name)
      |> Run.rm()
      |> Run.command(["sh", "-c", "echo hello; echo world"])

    # Stream callback with run -- note: run returns container ID from stdout,
    # but with streaming, lines go through callback and parse_output gets ""
    Docker.run(cmd, stream: fn line -> :ets.insert(lines, {:line, line}) end)

    collected = :ets.lookup(lines, :line) |> Enum.map(fn {:line, l} -> l end)
    :ets.delete(lines)

    assert "hello" in collected
    assert "world" in collected
  end

  test "ps works without stream (regression)" do
    {:ok, containers} = Docker.ps()
    assert is_list(containers)
  end

  test "facade functions pass stream option through" do
    lines = :ets.new(:facade_lines, [:bag, :public])

    name = "dw_test_fsc_#{:rand.uniform(100_000)}"

    Run.new(@image)
    |> Run.name(name)
    |> Run.detach()
    |> Run.command(["sh", "-c", "echo test_output; sleep 1"])
    |> Docker.run()

    Process.sleep(500)

    Docker.logs(name, stream: fn line -> :ets.insert(lines, {:line, line}) end)

    collected = :ets.lookup(lines, :line) |> Enum.map(fn {:line, l} -> l end)
    :ets.delete(lines)

    assert "test_output" in collected

    {:ok, _} = Docker.stop(name)
    Docker.rm(Rm.new(name) |> Rm.force())
  end
end
