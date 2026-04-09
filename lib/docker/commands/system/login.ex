defmodule Docker.Commands.System.Login do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker login`.
  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_opt: 3]

  defstruct [:server, :username, :password, :password_stdin]

  @type t :: %__MODULE__{}

  def new, do: %__MODULE__{}
  def new(server), do: %__MODULE__{server: server}

  def username(%__MODULE__{} = cmd, u), do: %{cmd | username: u}
  def password(%__MODULE__{} = cmd, p), do: %{cmd | password: p}

  @impl true
  def args(%__MODULE__{} = cmd) do
    base =
      ["login"]
      |> add_opt(cmd.username, "-u")
      |> add_opt(cmd.password, "-p")

    if cmd.server, do: base ++ [cmd.server], else: base
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, String.trim(stdout)}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
