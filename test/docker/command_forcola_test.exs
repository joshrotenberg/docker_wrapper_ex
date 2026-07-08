defmodule Docker.CommandForcolaTest do
  use ExUnit.Case, async: true

  alias Docker.Commands.Generic
  alias Docker.Config

  # These tests exercise the :forcola runner without needing docker: they point
  # the config binary at plain POSIX utilities. forcola is a POSIX-only optional
  # dependency, so skip on non-unix platforms.
  @moduletag :forcola

  setup do
    unless match?({:unix, _}, :os.type()) and Code.ensure_loaded?(Forcola) do
      raise "forcola runner tests require a POSIX platform with forcola loaded"
    end

    :ok
  end

  test "routes a buffered command through Forcola.run/2 and returns output" do
    cmd = Generic.new(["forcola-runner-ok"])
    config = Config.new(binary: "/bin/echo", runner: :forcola)

    assert {:ok, output} = Docker.Command.run(Generic, cmd, config)
    assert output =~ "forcola-runner-ok"
  end

  test "maps a forcola timeout to {:error, :timeout}" do
    cmd = Generic.new(["5"])
    config = Config.new(binary: "/bin/sleep", runner: :forcola, timeout: 100)

    assert {:error, :timeout} = Docker.Command.run(Generic, cmd, config)
  end

  test "falls back to :system when forcola cannot map the runner" do
    # A non-forcola runner uses System.cmd regardless of forcola availability.
    cmd = Generic.new(["system-runner-ok"])
    config = Config.new(binary: "/bin/echo", runner: :system)

    assert {:ok, output} = Docker.Command.run(Generic, cmd, config)
    assert output =~ "system-runner-ok"
  end
end
