defmodule Docker.Commands.Exec do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker exec`.

  ## Examples

      import Docker.Commands.Exec

      "my-container"
      |> new(["ls", "-la"])
      |> Docker.exec_cmd()

  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3, add_opt: 3, add_repeat: 3]

  @type t :: %__MODULE__{
          container: String.t(),
          command: [String.t()],
          detach: boolean(),
          interactive: boolean(),
          tty: boolean(),
          privileged: boolean(),
          user: String.t() | nil,
          workdir: String.t() | nil,
          env: [{String.t(), String.t()}]
        }

  @enforce_keys [:container, :command]
  defstruct [
    :container,
    :command,
    :user,
    :workdir,
    detach: false,
    interactive: false,
    tty: false,
    privileged: false,
    env: []
  ]

  def new(container, command) when is_list(command) do
    %__MODULE__{container: container, command: command}
  end

  def new(container, command) when is_binary(command) do
    %__MODULE__{container: container, command: [command]}
  end

  def detach(%__MODULE__{} = cmd), do: %{cmd | detach: true}
  def interactive(%__MODULE__{} = cmd), do: %{cmd | interactive: true}
  def tty(%__MODULE__{} = cmd), do: %{cmd | tty: true}
  def privileged(%__MODULE__{} = cmd), do: %{cmd | privileged: true}
  def user(%__MODULE__{} = cmd, u), do: %{cmd | user: u}
  def workdir(%__MODULE__{} = cmd, w), do: %{cmd | workdir: w}

  def env(%__MODULE__{} = cmd, key, value) do
    %{cmd | env: cmd.env ++ [{to_string(key), to_string(value)}]}
  end

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["exec"]
    |> add_flag(cmd.detach, "-d")
    |> add_flag(cmd.interactive, "-i")
    |> add_flag(cmd.tty, "-t")
    |> add_flag(cmd.privileged, "--privileged")
    |> add_opt(cmd.user, "--user")
    |> add_opt(cmd.workdir, "--workdir")
    |> add_repeat(cmd.env, fn {k, v} -> ["-e", "#{k}=#{v}"] end)
    |> Kernel.++([cmd.container])
    |> Kernel.++(cmd.command)
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, stdout}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
