defmodule Docker.Integration.ImageTest do
  use ExUnit.Case, async: false

  @moduletag :integration

  @image "alpine:latest"

  describe "pull" do
    test "pulls an image" do
      {:ok, output} = Docker.pull(@image)
      assert output =~ "alpine"
    end
  end

  describe "images" do
    test "lists images including the pulled one" do
      {:ok, _} = Docker.pull(@image)
      {:ok, images} = Docker.images()
      assert Enum.any?(images, fn i -> i["Repository"] == "alpine" end)
    end
  end

  describe "inspect" do
    test "inspects an image" do
      {:ok, _} = Docker.pull(@image)
      {:ok, [info]} = Docker.inspect_cmd(@image)
      assert is_map(info)
      assert info["RepoTags"] != nil
    end
  end

  describe "history" do
    test "shows image history" do
      {:ok, _} = Docker.pull(@image)
      {:ok, layers} = Docker.history(@image)
      assert is_list(layers)
      assert layers != []
    end
  end

  describe "tag/rmi" do
    test "tags and removes an image" do
      {:ok, _} = Docker.pull(@image)
      {:ok, :done} = Docker.tag(@image, "dw_test_tag:latest")

      {:ok, images} = Docker.images()
      assert Enum.any?(images, fn i -> i["Repository"] == "dw_test_tag" end)

      {:ok, _} = Docker.rmi("dw_test_tag:latest")

      {:ok, images} = Docker.images()
      refute Enum.any?(images, fn i -> i["Repository"] == "dw_test_tag" end)
    end
  end
end
