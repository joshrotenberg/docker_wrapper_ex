defmodule Docker.Commands.ComposeTest do
  use ExUnit.Case

  alias Docker.Commands.Compose

  describe "Compose.Up" do
    test "basic up" do
      args = Compose.Up.args(Compose.Up.new())
      assert args == ["compose", "up"]
    end

    test "with file, detach, and services" do
      args =
        Compose.Up.new()
        |> Compose.Up.file("docker-compose.yml")
        |> Compose.Up.detach()
        |> Compose.Up.service("redis")
        |> Compose.Up.service("web")
        |> Compose.Up.args()

      assert "compose" == hd(args)
      assert "-f" in args
      assert "docker-compose.yml" in args
      assert "-d" in args
      assert "redis" in args
      assert "web" in args
    end

    test "with build, force_recreate, remove_orphans" do
      args =
        Compose.Up.new()
        |> Compose.Up.build()
        |> Compose.Up.force_recreate()
        |> Compose.Up.remove_orphans()
        |> Compose.Up.wait()
        |> Compose.Up.args()

      assert "--build" in args
      assert "--force-recreate" in args
      assert "--remove-orphans" in args
      assert "--wait" in args
    end

    test "with project name and scale" do
      args =
        Compose.Up.new()
        |> Compose.Up.project_name("myproject")
        |> Compose.Up.scale("web", 3)
        |> Compose.Up.args()

      assert "-p" in args
      assert "myproject" in args
      assert "--scale" in args
      assert "web=3" in args
    end

    test "with pull policy and timeout" do
      args =
        Compose.Up.new()
        |> Compose.Up.pull_policy("always")
        |> Compose.Up.timeout(30)
        |> Compose.Up.args()

      assert "--pull" in args
      assert "always" in args
      assert "-t" in args
      assert "30" in args
    end
  end

  describe "Compose.Down" do
    test "basic down" do
      args = Compose.Down.args(Compose.Down.new())
      assert args == ["compose", "down"]
    end

    test "with volumes and rmi" do
      args =
        Compose.Down.new()
        |> Compose.Down.volumes()
        |> Compose.Down.rmi("all")
        |> Compose.Down.remove_orphans()
        |> Compose.Down.args()

      assert "-v" in args
      assert "--rmi" in args
      assert "all" in args
      assert "--remove-orphans" in args
    end
  end

  describe "Compose.Ps" do
    test "basic ps" do
      args = Compose.Ps.args(Compose.Ps.new())
      assert args == ["compose", "ps", "--format", "json"]
    end

    test "with all and status filter" do
      args =
        Compose.Ps.new()
        |> Compose.Ps.all()
        |> Compose.Ps.filter_status("running")
        |> Compose.Ps.args()

      assert "-a" in args
      assert "--status" in args
      assert "running" in args
    end
  end

  describe "Compose.Logs" do
    test "with follow and tail" do
      args =
        Compose.Logs.new()
        |> Compose.Logs.follow()
        |> Compose.Logs.tail(50)
        |> Compose.Logs.service("web")
        |> Compose.Logs.no_color()
        |> Compose.Logs.args()

      assert "-f" in args
      assert "--tail" in args
      assert "50" in args
      assert "--no-color" in args
      assert "web" == List.last(args)
    end
  end

  describe "Compose.Exec" do
    test "basic exec" do
      args = Compose.Exec.args(Compose.Exec.new("web", ["ls", "-la"]))
      assert "compose" == hd(args)
      assert "exec" in args
      assert "web" in args
      assert "ls" in args
      assert "-la" in args
    end

    test "with user and env" do
      args =
        Compose.Exec.new("web", ["bash"])
        |> Compose.Exec.user("root")
        |> Compose.Exec.env("DEBUG", "1")
        |> Compose.Exec.args()

      assert "--user" in args
      assert "root" in args
      assert "-e" in args
      assert "DEBUG=1" in args
    end
  end

  describe "Compose.Run" do
    test "basic run" do
      args =
        Compose.Run.new("web")
        |> Compose.Run.command(["rake", "test"])
        |> Compose.Run.rm()
        |> Compose.Run.args()

      assert "compose" == hd(args)
      assert "run" in args
      assert "--rm" in args
      assert "web" in args
      assert "rake" in args
      assert "test" in args
    end
  end

  describe "Compose.Build" do
    test "with build args" do
      args =
        Compose.Build.new()
        |> Compose.Build.service("web")
        |> Compose.Build.no_cache()
        |> Compose.Build.build_arg("VERSION", "1.0")
        |> Compose.Build.args()

      assert "build" in args
      assert "--no-cache" in args
      assert "--build-arg" in args
      assert "VERSION=1.0" in args
      assert "web" == List.last(args)
    end
  end

  describe "Compose.Config" do
    test "basic config" do
      args = Compose.Config.args(Compose.Config.new())
      assert args == ["compose", "config"]
    end

    test "with services only" do
      args = Compose.Config.new() |> Compose.Config.services_only() |> Compose.Config.args()
      assert "--services" in args
    end
  end

  describe "Compose.Stop" do
    test "with timeout and service" do
      args =
        Compose.Stop.new()
        |> Compose.Stop.timeout(10)
        |> Compose.Stop.service("web")
        |> Compose.Stop.args()

      assert "stop" in args
      assert "-t" in args
      assert "10" in args
      assert "web" == List.last(args)
    end
  end

  describe "Compose.Rm" do
    test "with force and stop" do
      args =
        Compose.Rm.new()
        |> Compose.Rm.force()
        |> Compose.Rm.stop()
        |> Compose.Rm.service("web")
        |> Compose.Rm.args()

      assert "rm" in args
      assert "-f" in args
      assert "-s" in args
    end
  end

  describe "Compose.Port" do
    test "basic port lookup" do
      args = Compose.Port.args(Compose.Port.new("web", 8080))
      assert "port" in args
      assert "web" in args
      assert "8080" in args
    end

    test "with protocol" do
      args = Compose.Port.new("web", 53) |> Compose.Port.protocol("udp") |> Compose.Port.args()
      assert "--protocol" in args
      assert "udp" in args
    end
  end

  describe "Compose.Create" do
    test "with build and scale" do
      args =
        Compose.Create.new()
        |> Compose.Create.build()
        |> Compose.Create.scale("web", 2)
        |> Compose.Create.args()

      assert "create" in args
      assert "--build" in args
      assert "--scale" in args
      assert "web=2" in args
    end
  end
end
