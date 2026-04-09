defmodule Docker.Commands.RemainingTest do
  use ExUnit.Case

  alias Docker.Commands.{Context, Generic, Init, Manifest, Swarm}

  describe "Generic" do
    test "passes args through" do
      args = Generic.args(Generic.new(["system", "events", "--filter", "type=container"]))
      assert args == ["system", "events", "--filter", "type=container"]
    end

    test "parse_output" do
      assert {:ok, "output"} = Generic.parse_output("output", 0)
      assert {:error, {"err", 1}} = Generic.parse_output("err", 1)
    end
  end

  describe "Init" do
    test "args" do
      assert Init.args(Init.new()) == ["init"]
    end
  end

  describe "Context.Create" do
    test "with description" do
      args =
        Context.Create.new("myctx")
        |> Context.Create.description("My context")
        |> Context.Create.args()

      assert args == ["context", "create", "--description", "My context", "myctx"]
    end
  end

  describe "Context.Ls" do
    test "default args" do
      assert Context.Ls.args(Context.Ls.new()) == ["context", "ls", "--format", "json"]
    end
  end

  describe "Context.Use" do
    test "args" do
      assert Context.Use.args(Context.Use.new("myctx")) == ["context", "use", "myctx"]
    end
  end

  describe "Context.Rm" do
    test "with force" do
      args = Context.Rm.new("myctx") |> Context.Rm.force() |> Context.Rm.args()
      assert args == ["context", "rm", "-f", "myctx"]
    end
  end

  describe "Swarm.Init" do
    test "with advertise addr" do
      args =
        Swarm.Init.new()
        |> Swarm.Init.advertise_addr("192.168.1.1")
        |> Swarm.Init.autolock()
        |> Swarm.Init.args()

      assert "--advertise-addr" in args
      assert "192.168.1.1" in args
      assert "--autolock" in args
    end
  end

  describe "Swarm.Join" do
    test "with token" do
      args =
        Swarm.Join.new("192.168.1.1:2377")
        |> Swarm.Join.token("SWMTKN-1-xxx")
        |> Swarm.Join.args()

      assert "--token" in args
      assert "SWMTKN-1-xxx" in args
      assert "192.168.1.1:2377" == List.last(args)
    end
  end

  describe "Swarm.Leave" do
    test "with force" do
      args = Swarm.Leave.new() |> Swarm.Leave.force() |> Swarm.Leave.args()
      assert args == ["swarm", "leave", "--force"]
    end
  end

  describe "Swarm.JoinToken" do
    test "worker token" do
      args = Swarm.JoinToken.new("worker") |> Swarm.JoinToken.quiet() |> Swarm.JoinToken.args()
      assert args == ["swarm", "join-token", "-q", "worker"]
    end
  end

  describe "Manifest.Create" do
    test "with manifests" do
      args =
        Manifest.Create.args(Manifest.Create.new("myimg:latest", ["myimg:amd64", "myimg:arm64"]))

      assert "manifest" == hd(args)
      assert "create" in args
      assert "myimg:latest" in args
      assert "myimg:amd64" in args
      assert "myimg:arm64" in args
    end
  end

  describe "Manifest.Annotate" do
    test "with arch and os" do
      args =
        Manifest.Annotate.new("myimg:latest", "myimg:arm64")
        |> Manifest.Annotate.arch("arm64")
        |> Manifest.Annotate.os("linux")
        |> Manifest.Annotate.args()

      assert "--arch" in args
      assert "arm64" in args
      assert "--os" in args
      assert "linux" in args
    end
  end

  describe "Manifest.Push" do
    test "with purge" do
      args = Manifest.Push.new("myimg:latest") |> Manifest.Push.purge() |> Manifest.Push.args()
      assert "--purge" in args
    end
  end

  describe "Manifest.Rm" do
    test "args" do
      assert Manifest.Rm.args(Manifest.Rm.new("myimg:latest")) ==
               ["manifest", "rm", "myimg:latest"]
    end
  end
end
