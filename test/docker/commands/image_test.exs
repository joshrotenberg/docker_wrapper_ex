defmodule Docker.Commands.ImageTest do
  use ExUnit.Case

  alias Docker.Commands.{Build, History, Images, Import, Load, Pull, Push, Rmi, Save, Search, Tag}

  describe "Images" do
    test "default args" do
      assert Images.args(Images.new()) == ["images", "--format", "json"]
    end

    test "with all and filter" do
      args =
        Images.new()
        |> Images.all()
        |> Images.filter("dangling=true")
        |> Images.args()

      assert "-a" in args
      assert "--filter" in args
      assert "dangling=true" in args
    end

    test "with repository" do
      args = Images.args(Images.new("nginx"))
      assert List.last(args) == "nginx"
    end

    test "parse_output with JSON lines" do
      json = ~s({"Repository":"nginx","Tag":"latest","Size":"100MB"}\n)
      {:ok, images} = Images.parse_output(json, 0)
      assert length(images) == 1
      assert hd(images)["Repository"] == "nginx"
    end
  end

  describe "Pull" do
    test "basic pull" do
      assert Pull.args(Pull.new("nginx:alpine")) == ["pull", "nginx:alpine"]
    end

    test "with platform" do
      args = Pull.new("nginx") |> Pull.platform("linux/amd64") |> Pull.args()
      assert args == ["pull", "--platform", "linux/amd64", "nginx"]
    end

    test "with all tags and quiet" do
      args = Pull.new("nginx") |> Pull.all_tags() |> Pull.quiet() |> Pull.args()
      assert "-a" in args
      assert "-q" in args
    end
  end

  describe "Push" do
    test "basic push" do
      assert Push.args(Push.new("myrepo/myimage:v1")) == ["push", "myrepo/myimage:v1"]
    end

    test "with all tags" do
      args = Push.new("myrepo/myimage") |> Push.all_tags() |> Push.args()
      assert "-a" in args
    end
  end

  describe "Build" do
    test "basic build" do
      assert Build.args(Build.new(".")) == ["build", "--rm", "."]
    end

    test "with tag and dockerfile" do
      args =
        "."
        |> Build.new()
        |> Build.tag("myapp:latest")
        |> Build.file("Dockerfile.prod")
        |> Build.args()

      assert "-t" in args
      assert "myapp:latest" in args
      assert "-f" in args
      assert "Dockerfile.prod" in args
    end

    test "with build args and labels" do
      args =
        "."
        |> Build.new()
        |> Build.build_arg("VERSION", "1.0")
        |> Build.label("maintainer", "test")
        |> Build.args()

      assert "--build-arg" in args
      assert "VERSION=1.0" in args
      assert "--label" in args
      assert "maintainer=test" in args
    end

    test "with no_cache and pull" do
      args = Build.new(".") |> Build.no_cache() |> Build.pull() |> Build.args()
      assert "--no-cache" in args
      assert "--pull" in args
    end

    test "with target and platform" do
      args =
        Build.new(".")
        |> Build.target("builder")
        |> Build.platform("linux/amd64")
        |> Build.args()

      assert "--target" in args
      assert "builder" in args
      assert "--platform" in args
      assert "linux/amd64" in args
    end

    test "extra args placed before context" do
      args = Build.new(".") |> Build.raw(["--ssh", "default"]) |> Build.args()
      ssh_idx = Enum.find_index(args, &(&1 == "--ssh"))
      ctx_idx = Enum.find_index(args, &(&1 == "."))
      assert ssh_idx < ctx_idx
    end
  end

  describe "Tag" do
    test "basic tag" do
      assert Tag.args(Tag.new("nginx:latest", "myrepo/nginx:v1")) ==
               ["tag", "nginx:latest", "myrepo/nginx:v1"]
    end

    test "parse_output" do
      assert Tag.parse_output("", 0) == {:ok, :done}
    end
  end

  describe "Rmi" do
    test "single image" do
      assert Rmi.args(Rmi.new("nginx:old")) == ["rmi", "nginx:old"]
    end

    test "multiple with force" do
      args = Rmi.new(["img1", "img2"]) |> Rmi.force() |> Rmi.args()
      assert args == ["rmi", "-f", "img1", "img2"]
    end

    test "with no_prune" do
      args = Rmi.new("img") |> Rmi.no_prune() |> Rmi.args()
      assert "--no-prune" in args
    end
  end

  describe "Save" do
    test "basic save" do
      assert Save.args(Save.new("nginx")) == ["save", "nginx"]
    end

    test "with output" do
      args = Save.new("nginx") |> Save.output("/tmp/nginx.tar") |> Save.args()
      assert args == ["save", "-o", "/tmp/nginx.tar", "nginx"]
    end

    test "multiple images" do
      args = Save.args(Save.new(["nginx", "redis"]))
      assert args == ["save", "nginx", "redis"]
    end
  end

  describe "Load" do
    test "basic load" do
      assert Load.args(Load.new()) == ["load"]
    end

    test "with input" do
      args = Load.new("/tmp/nginx.tar") |> Load.args()
      assert args == ["load", "-i", "/tmp/nginx.tar"]
    end

    test "with quiet" do
      args = Load.new() |> Load.quiet() |> Load.input("/tmp/x.tar") |> Load.args()
      assert "-q" in args
      assert "-i" in args
    end
  end

  describe "Import" do
    test "basic import" do
      assert Import.args(Import.new("/tmp/fs.tar")) == ["import", "/tmp/fs.tar"]
    end

    test "with repository and message" do
      args =
        "/tmp/fs.tar"
        |> Import.new()
        |> Import.repository("myimage:latest")
        |> Import.message("imported from backup")
        |> Import.args()

      assert "-m" in args
      assert "imported from backup" in args
      assert "myimage:latest" == List.last(args)
    end

    test "with changes" do
      args =
        "/tmp/fs.tar"
        |> Import.new()
        |> Import.change("CMD /app/start")
        |> Import.args()

      assert "--change" in args
      assert "CMD /app/start" in args
    end
  end

  describe "History" do
    test "basic history" do
      assert History.args(History.new("nginx")) == ["history", "--format", "json", "nginx"]
    end

    test "with no_trunc" do
      args = History.new("nginx") |> History.no_trunc() |> History.args()
      assert "--no-trunc" in args
    end

    test "parse_output" do
      json = ~s({"CreatedBy":"CMD","Size":"0B"}\n)
      {:ok, layers} = History.parse_output(json, 0)
      assert length(layers) == 1
    end
  end

  describe "Search" do
    test "basic search" do
      assert Search.args(Search.new("nginx")) == ["search", "--format", "json", "nginx"]
    end

    test "with limit and filter" do
      args =
        "redis"
        |> Search.new()
        |> Search.limit(10)
        |> Search.filter("is-official=true")
        |> Search.args()

      assert "--limit" in args
      assert "10" in args
      assert "--filter" in args
      assert "is-official=true" in args
    end

    test "parse_output" do
      json = ~s({"Name":"nginx","Description":"Official","StarCount":100}\n)
      {:ok, results} = Search.parse_output(json, 0)
      assert hd(results)["Name"] == "nginx"
    end
  end
end
