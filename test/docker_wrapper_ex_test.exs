defmodule DockerTest do
  use ExUnit.Case

  alias Docker.Config

  describe "Config" do
    test "new/0 creates config with auto-detected binary" do
      config = Config.new()
      assert config.binary != nil
      assert config.timeout == 30_000
      assert config.env == []
      assert config.working_dir == nil
    end

    test "new/1 accepts options" do
      config = Config.new(binary: "/usr/bin/docker", timeout: 60_000, working_dir: "/tmp")
      assert config.binary == "/usr/bin/docker"
      assert config.timeout == 60_000
      assert config.working_dir == "/tmp"
    end

    test "base_args/1 returns empty list" do
      assert Config.base_args(Config.new()) == []
    end

    test "cmd_opts/1 includes stderr_to_stdout" do
      opts = Config.cmd_opts(Config.new())
      assert Keyword.get(opts, :stderr_to_stdout) == true
    end

    test "cmd_opts/1 includes cd when working_dir is set" do
      opts = Config.cmd_opts(Config.new(working_dir: "/tmp"))
      assert Keyword.get(opts, :cd) == "/tmp"
    end

    test "cmd_opts/1 includes env when set" do
      opts = Config.cmd_opts(Config.new(env: [{"FOO", "bar"}]))
      assert Keyword.get(opts, :env) == [{"FOO", "bar"}]
    end
  end
end
