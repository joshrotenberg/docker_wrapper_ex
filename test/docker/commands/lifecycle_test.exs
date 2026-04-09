defmodule Docker.Commands.LifecycleTest do
  use ExUnit.Case

  alias Docker.Commands.{Create, Kill, Pause, Restart, Rm, Start, Stop, Unpause}

  describe "Create" do
    test "args for basic create" do
      args = Create.args(Create.new("nginx"))
      assert args == ["create", "nginx"]
    end

    test "args with options" do
      args =
        "redis:7"
        |> Create.new()
        |> Create.name("my-redis")
        |> Create.port(6379, 6379)
        |> Create.args()

      assert "create" == hd(args)
      assert "--name" in args
      assert "my-redis" in args
      assert "-p" in args
      assert "6379:6379/tcp" in args
    end

    test "parse_output success" do
      {:ok, cid} = Create.parse_output("abc123\n", 0)
      assert cid.full == "abc123"
    end
  end

  describe "Start" do
    test "args for single container" do
      assert Start.args(Start.new("abc123")) == ["start", "abc123"]
    end

    test "args for multiple containers" do
      assert Start.args(Start.new(["abc", "def"])) == ["start", "abc", "def"]
    end

    test "args with attach" do
      args = Start.new("abc") |> Start.attach() |> Start.args()
      assert args == ["start", "-a", "abc"]
    end
  end

  describe "Stop" do
    test "args for single container" do
      assert Stop.args(Stop.new("abc123")) == ["stop", "abc123"]
    end

    test "args with timeout" do
      args = Stop.new("abc") |> Stop.time(10) |> Stop.args()
      assert args == ["stop", "-t", "10", "abc"]
    end
  end

  describe "Kill" do
    test "args for single container" do
      assert Kill.args(Kill.new("abc123")) == ["kill", "abc123"]
    end

    test "args with signal" do
      args = Kill.new("abc") |> Kill.signal("SIGTERM") |> Kill.args()
      assert args == ["kill", "--signal", "SIGTERM", "abc"]
    end
  end

  describe "Rm" do
    test "args for single container" do
      assert Rm.args(Rm.new("abc123")) == ["rm", "abc123"]
    end

    test "args with force and volumes" do
      args = Rm.new("abc") |> Rm.force() |> Rm.volumes() |> Rm.args()
      assert args == ["rm", "-f", "-v", "abc"]
    end

    test "args for multiple containers" do
      assert Rm.args(Rm.new(["abc", "def"])) == ["rm", "abc", "def"]
    end
  end

  describe "Restart" do
    test "args for single container" do
      assert Restart.args(Restart.new("abc123")) == ["restart", "abc123"]
    end

    test "args with timeout" do
      args = Restart.new("abc") |> Restart.time(5) |> Restart.args()
      assert args == ["restart", "-t", "5", "abc"]
    end
  end

  describe "Pause" do
    test "args for single container" do
      assert Pause.args(Pause.new("abc123")) == ["pause", "abc123"]
    end

    test "args for multiple containers" do
      assert Pause.args(Pause.new(["abc", "def"])) == ["pause", "abc", "def"]
    end
  end

  describe "Unpause" do
    test "args for single container" do
      assert Unpause.args(Unpause.new("abc123")) == ["unpause", "abc123"]
    end
  end
end
