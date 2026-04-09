defmodule Docker.Debug.ExecutorTest do
  use ExUnit.Case

  alias Docker.Commands.{Ps, Run}
  alias Docker.Debug.{Config, Executor}

  describe "dry_run" do
    test "returns the command string without executing" do
      cmd = Run.new("nginx:alpine") |> Run.name("test")
      debug = Config.new(dry_run: true)
      config = Docker.Config.new()

      {:ok, cmd_string} = Executor.run(Run, cmd, config, debug)

      assert cmd_string =~ "docker"
      assert cmd_string =~ "run"
      assert cmd_string =~ "--name"
      assert cmd_string =~ "test"
      assert cmd_string =~ "nginx:alpine"
    end

    test "dry_run with detach and port" do
      cmd =
        Run.new("redis:7")
        |> Run.detach()
        |> Run.port(6379, 6379)

      debug = Config.new(dry_run: true)
      config = Docker.Config.new()

      {:ok, cmd_string} = Executor.run(Run, cmd, config, debug)
      assert cmd_string =~ "-d"
      assert cmd_string =~ "-p"
      assert cmd_string =~ "6379:6379/tcp"
    end

    test "dry_run for ps" do
      cmd = Ps.new() |> Ps.all()
      debug = Config.new(dry_run: true)
      config = Docker.Config.new()

      {:ok, cmd_string} = Executor.run(Ps, cmd, config, debug)
      assert cmd_string =~ "ps"
      assert cmd_string =~ "-a"
    end
  end
end
