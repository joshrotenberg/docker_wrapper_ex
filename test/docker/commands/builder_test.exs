defmodule Docker.Commands.BuilderTest do
  use ExUnit.Case

  alias Docker.Commands.Builder

  describe "Builder.Create" do
    test "basic create" do
      args = Builder.Create.args(Builder.Create.new())
      assert args == ["buildx", "create"]
    end

    test "with driver and use" do
      args =
        Builder.Create.new()
        |> Builder.Create.name("mybuilder")
        |> Builder.Create.driver("docker-container")
        |> Builder.Create.use()
        |> Builder.Create.args()

      assert "--name" in args
      assert "mybuilder" in args
      assert "--driver" in args
      assert "docker-container" in args
      assert "--use" in args
    end
  end

  describe "Builder.Build" do
    test "multi-platform build" do
      args =
        Builder.Build.new(".")
        |> Builder.Build.tag("myapp:latest")
        |> Builder.Build.platform("linux/amd64")
        |> Builder.Build.platform("linux/arm64")
        |> Builder.Build.push()
        |> Builder.Build.args()

      assert "buildx" == hd(args)
      assert "build" in args
      assert "--push" in args
      assert "-t" in args
      assert "myapp:latest" in args
      assert "--platform" in args
      assert "linux/amd64,linux/arm64" in args
      assert "." == List.last(args)
    end

    test "with cache options" do
      args =
        Builder.Build.new(".")
        |> Builder.Build.cache_from("type=registry,ref=myapp:cache")
        |> Builder.Build.cache_to("type=registry,ref=myapp:cache")
        |> Builder.Build.args()

      assert "--cache-from" in args
      assert "--cache-to" in args
    end
  end

  describe "Builder.Bake" do
    test "basic bake" do
      args = Builder.Bake.args(Builder.Bake.new())
      assert args == ["buildx", "bake"]
    end

    test "with targets and print" do
      args =
        Builder.Bake.new()
        |> Builder.Bake.target("app")
        |> Builder.Bake.print()
        |> Builder.Bake.args()

      assert "--print" in args
      assert "app" == List.last(args)
    end
  end

  describe "Builder.Ls" do
    test "args" do
      assert Builder.Ls.args(Builder.Ls.new()) == ["buildx", "ls"]
    end
  end

  describe "Builder.Rm" do
    test "with force" do
      args = Builder.Rm.new("mybuilder") |> Builder.Rm.force() |> Builder.Rm.args()
      assert args == ["buildx", "rm", "-f", "mybuilder"]
    end
  end

  describe "Builder.Use" do
    test "basic use" do
      args = Builder.Use.args(Builder.Use.new("mybuilder"))
      assert args == ["buildx", "use", "mybuilder"]
    end
  end

  describe "Builder.Prune" do
    test "with all and keep-storage" do
      args =
        Builder.Prune.new()
        |> Builder.Prune.all()
        |> Builder.Prune.keep_storage("10GB")
        |> Builder.Prune.args()

      assert "builder" == hd(args)
      assert "-a" in args
      assert "--keep-storage" in args
      assert "10GB" in args
    end
  end
end
