defmodule Docker.Commands.InspectionTest do
  use ExUnit.Case

  alias Docker.Commands.{Exec, Inspect, Logs, Ps}

  describe "Ps" do
    test "args for default ps" do
      args = Ps.args(Ps.new())
      assert args == ["ps", "--format", "json"]
    end

    test "args with all and filters" do
      args =
        Ps.new()
        |> Ps.all()
        |> Ps.filter("name=redis")
        |> Ps.filter("status=running")
        |> Ps.args()

      assert "ps" == hd(args)
      assert "-a" in args
      assert "--filter" in args
      assert "name=redis" in args
      assert "status=running" in args
    end

    test "args with quiet and last" do
      args = Ps.new() |> Ps.quiet() |> Ps.last(5) |> Ps.args()
      assert "-q" in args
      assert "-n" in args
      assert "5" in args
    end

    test "parse_output with JSON lines" do
      json =
        ~s({"ID":"abc123","Names":"redis","State":"running"}\n{"ID":"def456","Names":"nginx","State":"running"}\n)

      {:ok, containers} = Ps.parse_output(json, 0)
      assert length(containers) == 2
      assert hd(containers)["ID"] == "abc123"
    end

    test "parse_output with empty output" do
      {:ok, containers} = Ps.parse_output("", 0)
      assert containers == []
    end
  end

  describe "Logs" do
    test "args for basic logs" do
      args = Logs.args(Logs.new("abc123"))
      assert args == ["logs", "abc123"]
    end

    test "args with follow and tail" do
      args =
        "abc123"
        |> Logs.new()
        |> Logs.follow()
        |> Logs.tail(100)
        |> Logs.timestamps()
        |> Logs.args()

      assert "-f" in args
      assert "--tail" in args
      assert "100" in args
      assert "-t" in args
      assert "abc123" == List.last(args)
    end

    test "args with since and until" do
      args =
        "abc123"
        |> Logs.new()
        |> Logs.since("2024-01-01")
        |> Logs.until_time("2024-12-31")
        |> Logs.args()

      assert "--since" in args
      assert "2024-01-01" in args
      assert "--until" in args
      assert "2024-12-31" in args
    end
  end

  describe "Inspect" do
    test "args for single target" do
      args = Inspect.args(Inspect.new("abc123"))
      assert args == ["inspect", "abc123"]
    end

    test "args with type" do
      args = Inspect.new("abc123") |> Inspect.type("container") |> Inspect.args()
      assert args == ["inspect", "--type", "container", "abc123"]
    end

    test "args for multiple targets" do
      args = Inspect.args(Inspect.new(["abc", "def"]))
      assert args == ["inspect", "abc", "def"]
    end

    test "parse_output with valid JSON" do
      json = ~s([{"Id": "abc123", "Name": "/redis"}])
      {:ok, data} = Inspect.parse_output(json, 0)
      assert length(data) == 1
      assert hd(data)["Id"] == "abc123"
    end

    test "parse_output with invalid JSON" do
      {:error, {:json_parse_error, _}} = Inspect.parse_output("not json", 0)
    end
  end

  describe "Exec" do
    test "args for basic exec" do
      args = Exec.args(Exec.new("abc123", ["ls", "-la"]))
      assert args == ["exec", "abc123", "ls", "-la"]
    end

    test "args with interactive tty" do
      args =
        Exec.new("abc123", ["bash"])
        |> Exec.interactive()
        |> Exec.tty()
        |> Exec.args()

      assert args == ["exec", "-i", "-t", "abc123", "bash"]
    end

    test "args with env and user" do
      args =
        Exec.new("abc123", ["env"])
        |> Exec.user("root")
        |> Exec.workdir("/app")
        |> Exec.env("FOO", "bar")
        |> Exec.args()

      assert "--user" in args
      assert "root" in args
      assert "--workdir" in args
      assert "/app" in args
      assert "-e" in args
      assert "FOO=bar" in args
    end

    test "new/2 with string command" do
      cmd = Exec.new("abc123", "bash")
      assert cmd.command == ["bash"]
    end
  end
end
