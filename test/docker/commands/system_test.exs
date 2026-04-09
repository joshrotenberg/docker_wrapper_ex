defmodule Docker.Commands.SystemTest do
  use ExUnit.Case

  alias Docker.Commands.System, as: Sys

  describe "System.Version" do
    test "default args" do
      assert Sys.Version.args(Sys.Version.new()) == ["version"]
    end

    test "with json format" do
      args = Sys.Version.new() |> Sys.Version.json() |> Sys.Version.args()
      assert args == ["version", "--format", "json"]
    end

    test "parse_output with json" do
      json = ~s({"Client":{"Version":"24.0"}})
      {:ok, data} = Sys.Version.parse_output(json, 0)
      assert data["Client"]["Version"] == "24.0"
    end

    test "parse_output with plain text" do
      text = "Docker version 24.0.0"
      {:ok, result} = Sys.Version.parse_output(text, 0)
      assert result == text
    end
  end

  describe "System.Info" do
    test "with json" do
      args = Sys.Info.new() |> Sys.Info.json() |> Sys.Info.args()
      assert args == ["info", "--format", "json"]
    end
  end

  describe "System.Events" do
    test "with filters and since" do
      args =
        Sys.Events.new()
        |> Sys.Events.since("2024-01-01")
        |> Sys.Events.filter("type=container")
        |> Sys.Events.json()
        |> Sys.Events.args()

      assert "--since" in args
      assert "2024-01-01" in args
      assert "--filter" in args
      assert "type=container" in args
      assert "--format" in args
      assert "json" in args
    end
  end

  describe "System.Df" do
    test "default args" do
      assert Sys.Df.args(Sys.Df.new()) == ["system", "df"]
    end

    test "with verbose" do
      args = Sys.Df.new() |> Sys.Df.verbose() |> Sys.Df.args()
      assert "-v" in args
    end
  end

  describe "System.Prune" do
    test "default args" do
      assert Sys.Prune.args(Sys.Prune.new()) == ["system", "prune", "-f"]
    end

    test "with all and volumes" do
      args = Sys.Prune.new() |> Sys.Prune.all() |> Sys.Prune.volumes() |> Sys.Prune.args()
      assert "-a" in args
      assert "--volumes" in args
    end
  end

  describe "System.Login" do
    test "with username and server" do
      args =
        Sys.Login.new("registry.example.com")
        |> Sys.Login.username("user")
        |> Sys.Login.args()

      assert args == ["login", "-u", "user", "registry.example.com"]
    end
  end

  describe "System.Logout" do
    test "default" do
      assert Sys.Logout.args(Sys.Logout.new()) == ["logout"]
    end

    test "with server" do
      assert Sys.Logout.args(Sys.Logout.new("registry.example.com")) ==
               ["logout", "registry.example.com"]
    end
  end
end
