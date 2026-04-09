defmodule Docker.Commands.Compose.Common do
  @moduledoc """
  Shared fields and arg helpers for compose subcommands.

  All compose commands support project-level options like `-f` (file),
  `-p` (project name), and `--env-file`. This module provides macros
  and functions to avoid duplicating that logic.
  """

  import Docker.Command, only: [add_opt: 3, add_repeat: 3]

  @doc """
  Builds the compose prefix args from common fields.

  Returns `["compose", "-f", file, "-p", project, ...]` with only
  non-nil values included.
  """
  @spec compose_prefix(struct()) :: [String.t()]
  def compose_prefix(cmd) do
    ["compose"]
    |> add_repeat(Map.get(cmd, :files, []), fn f -> ["-f", f] end)
    |> add_opt(Map.get(cmd, :project_name), "-p")
    |> add_opt(Map.get(cmd, :project_directory), "--project-directory")
    |> add_repeat(Map.get(cmd, :env_files, []), fn f -> ["--env-file", f] end)
    |> add_repeat(Map.get(cmd, :profiles, []), fn p -> ["--profile", p] end)
  end

  @doc """
  Common compose fields to include in defstruct.
  """
  defmacro compose_fields(extra \\ []) do
    quote do
      unquote(extra) ++
        [
          files: [],
          project_name: nil,
          project_directory: nil,
          env_files: [],
          profiles: []
        ]
    end
  end
end
