defmodule Docker.ContainerIdTest do
  use ExUnit.Case
  doctest Docker.ContainerId

  alias Docker.ContainerId

  test "parse/1 trims whitespace and extracts short id" do
    cid = ContainerId.parse("abc123def456789012345678\n")
    assert cid.full == "abc123def456789012345678"
    assert cid.short == "abc123de"
  end

  test "parse/1 with short input" do
    cid = ContainerId.parse("abc\n")
    assert cid.full == "abc"
    assert cid.short == "abc"
  end
end
