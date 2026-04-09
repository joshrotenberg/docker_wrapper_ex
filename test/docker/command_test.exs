defmodule Docker.CommandTest do
  use ExUnit.Case

  alias Docker.Commands.Run

  describe "stream option" do
    @tag :integration
    test "streams output lines through callback" do
      lines = :ets.new(:lines, [:bag, :public])

      cmd =
        Run.new("alpine:latest")
        |> Run.rm()
        |> Run.command(["sh", "-c", "echo line1; echo line2; echo line3"])

      config = Docker.Config.new()

      {:ok, _} =
        Docker.Command.run(Run, cmd, config,
          stream: fn line -> :ets.insert(lines, {:line, line}) end
        )

      collected = :ets.lookup(lines, :line) |> Enum.map(fn {:line, l} -> l end)
      :ets.delete(lines)

      assert "line1" in collected
      assert "line2" in collected
      assert "line3" in collected
    end
  end
end
