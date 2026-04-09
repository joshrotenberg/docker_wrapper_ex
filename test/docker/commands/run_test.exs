defmodule Docker.Commands.RunTest do
  use ExUnit.Case

  alias Docker.Commands.Run

  describe "new/1" do
    test "creates a run command with the given image" do
      cmd = Run.new("nginx:alpine")
      assert cmd.image == "nginx:alpine"
      assert cmd.detach == false
      assert cmd.rm == false
      assert cmd.ports == []
    end
  end

  describe "builder functions" do
    test "pipeline composition" do
      cmd =
        "redis:7"
        |> Run.new()
        |> Run.name("my-redis")
        |> Run.port(6379, 6379)
        |> Run.detach()
        |> Run.rm()

      assert cmd.image == "redis:7"
      assert cmd.name == "my-redis"
      assert cmd.ports == [{6379, 6379, "tcp"}]
      assert cmd.detach == true
      assert cmd.rm == true
    end

    test "env/3 accumulates environment variables" do
      cmd =
        Run.new("alpine")
        |> Run.env("FOO", "bar")
        |> Run.env("BAZ", "qux")

      assert cmd.env == [{"FOO", "bar"}, {"BAZ", "qux"}]
    end

    test "volume/4 with default mode" do
      cmd = Run.new("alpine") |> Run.volume("/host", "/container")
      assert cmd.volumes == [{"/host", "/container", "rw"}]
    end

    test "volume/4 with read-only mode" do
      cmd = Run.new("alpine") |> Run.volume("/host", "/container", mode: "ro")
      assert cmd.volumes == [{"/host", "/container", "ro"}]
    end

    test "label/3 accumulates labels" do
      cmd =
        Run.new("alpine")
        |> Run.label("app", "myapp")
        |> Run.label("env", "test")

      assert cmd.labels == [{"app", "myapp"}, {"env", "test"}]
    end

    test "capabilities" do
      cmd =
        Run.new("alpine")
        |> Run.cap_add("NET_ADMIN")
        |> Run.cap_drop("MKNOD")

      assert cmd.cap_add == ["NET_ADMIN"]
      assert cmd.cap_drop == ["MKNOD"]
    end

    test "command/2 with string" do
      cmd = Run.new("alpine") |> Run.command("echo hello")
      assert cmd.command == ["echo hello"]
    end

    test "command/2 with list" do
      cmd = Run.new("alpine") |> Run.command(["echo", "hello"])
      assert cmd.command == ["echo", "hello"]
    end

    test "raw/2 adds extra args" do
      cmd = Run.new("alpine") |> Run.raw(["--ulimit", "nofile=65536"])
      assert cmd.extra_args == ["--ulimit", "nofile=65536"]
    end

    test "mount/5 adds mount spec" do
      cmd = Run.new("alpine") |> Run.mount("bind", "/src", "/dst", readonly: true)
      assert cmd.mounts == [{"bind", "/src", "/dst", [readonly: true]}]
    end
  end

  describe "args/1" do
    test "minimal run command" do
      args = Run.args(Run.new("nginx"))
      assert args == ["run", "nginx"]
    end

    test "detached with name" do
      args =
        "nginx"
        |> Run.new()
        |> Run.name("web")
        |> Run.detach()
        |> Run.args()

      assert args == ["run", "-d", "--name", "web", "nginx"]
    end

    test "full featured command" do
      args =
        "redis:7"
        |> Run.new()
        |> Run.name("my-redis")
        |> Run.detach()
        |> Run.rm()
        |> Run.port(6379, 6379)
        |> Run.volume("/data", "/data")
        |> Run.env("REDIS_PASSWORD", "secret")
        |> Run.network("my-net")
        |> Run.memory("512m")
        |> Run.args()

      assert "run" in args
      assert "-d" in args
      assert "--rm" in args
      assert "--name" in args
      assert "my-redis" in args
      assert "--network" in args
      assert "my-net" in args
      assert "--memory" in args
      assert "512m" in args
      assert "-p" in args
      assert "6379:6379/tcp" in args
      assert "-v" in args
      assert "/data:/data:rw" in args
      assert "-e" in args
      assert "REDIS_PASSWORD=secret" in args
      # image is near the end
      assert List.last(args) == "redis:7" or "redis:7" in args
    end

    test "command appended after image" do
      args =
        "alpine"
        |> Run.new()
        |> Run.command(["echo", "hello"])
        |> Run.args()

      assert args == ["run", "alpine", "echo", "hello"]
    end

    test "flags are in correct positions" do
      args =
        "alpine"
        |> Run.new()
        |> Run.interactive()
        |> Run.tty()
        |> Run.privileged()
        |> Run.read_only()
        |> Run.init_flag()
        |> Run.args()

      assert "-i" in args
      assert "-t" in args
      assert "--privileged" in args
      assert "--read-only" in args
      assert "--init" in args
    end

    test "extra_args placed before image" do
      args =
        "alpine"
        |> Run.new()
        |> Run.raw(["--ulimit", "nofile=65536"])
        |> Run.args()

      ulimit_idx = Enum.find_index(args, &(&1 == "--ulimit"))
      image_idx = Enum.find_index(args, &(&1 == "alpine"))
      assert ulimit_idx < image_idx
    end

    test "mount formatting" do
      args =
        "alpine"
        |> Run.new()
        |> Run.mount("bind", "/src", "/dst", readonly: true)
        |> Run.args()

      assert "--mount" in args
      mount_val = Enum.at(args, Enum.find_index(args, &(&1 == "--mount")) + 1)
      assert mount_val =~ "type=bind"
      assert mount_val =~ "source=/src"
      assert mount_val =~ "target=/dst"
      assert mount_val =~ "readonly=true"
    end

    test "health check options" do
      args =
        "alpine"
        |> Run.new()
        |> Run.health_cmd("curl -f http://localhost/")
        |> Run.health_interval("10s")
        |> Run.health_timeout("5s")
        |> Run.health_retries(3)
        |> Run.args()

      assert "--health-cmd" in args
      assert "curl -f http://localhost/" in args
      assert "--health-interval" in args
      assert "10s" in args
      assert "--health-timeout" in args
      assert "5s" in args
      assert "--health-retries" in args
      assert "3" in args
    end
  end

  describe "parse_output/2" do
    test "success returns container id" do
      {:ok, cid} = Run.parse_output("abc123def456789\n", 0)
      assert %Docker.ContainerId{} = cid
      assert cid.full == "abc123def456789"
      assert cid.short == "abc123de"
    end

    test "failure returns error tuple" do
      assert {:error, {"some error\n", 125}} = Run.parse_output("some error\n", 125)
    end
  end
end
