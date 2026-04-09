defmodule Docker.Commands.Logs do
  @moduledoc """
  Implements the `Docker.Command` behaviour for `docker logs`.

  ## Examples

      import Docker.Commands.Logs

      "my-container"
      |> new()
      |> tail(100)
      |> timestamps()
      |> Docker.logs()

  """

  @behaviour Docker.Command

  import Docker.Command, only: [add_flag: 3, add_opt: 3]

  @type t :: %__MODULE__{
          container: String.t(),
          follow: boolean(),
          timestamps: boolean(),
          tail: String.t() | nil,
          since: String.t() | nil,
          until_time: String.t() | nil,
          details: boolean()
        }

  @enforce_keys [:container]
  defstruct [
    :container,
    :tail,
    :since,
    :until_time,
    follow: false,
    timestamps: false,
    details: false
  ]

  def new(container), do: %__MODULE__{container: container}

  def follow(%__MODULE__{} = cmd), do: %{cmd | follow: true}
  def timestamps(%__MODULE__{} = cmd), do: %{cmd | timestamps: true}
  def details(%__MODULE__{} = cmd), do: %{cmd | details: true}
  def tail(%__MODULE__{} = cmd, n), do: %{cmd | tail: to_string(n)}
  def since(%__MODULE__{} = cmd, s), do: %{cmd | since: s}
  def until_time(%__MODULE__{} = cmd, u), do: %{cmd | until_time: u}

  @impl true
  def args(%__MODULE__{} = cmd) do
    ["logs"]
    |> add_flag(cmd.follow, "-f")
    |> add_flag(cmd.timestamps, "-t")
    |> add_flag(cmd.details, "--details")
    |> add_opt(cmd.tail, "--tail")
    |> add_opt(cmd.since, "--since")
    |> add_opt(cmd.until_time, "--until")
    |> Kernel.++([cmd.container])
  end

  @impl true
  def parse_output(stdout, 0), do: {:ok, stdout}
  def parse_output(stdout, exit_code), do: {:error, {stdout, exit_code}}
end
