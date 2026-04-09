defmodule Docker.Debug.Retry do
  @moduledoc """
  Retry policy for Docker command execution.

  Configures how many times to retry a failed command, the backoff
  strategy between attempts, and which errors are retryable.

  ## Examples

      # Exponential backoff, 3 attempts
      policy = Docker.Debug.Retry.new()

      # Custom policy
      policy = Docker.Debug.Retry.new(
        max_attempts: 5,
        backoff: :linear,
        base_delay: 1_000,
        max_delay: 30_000
      )

  """

  @type backoff :: :exponential | :linear | :constant
  @type retryable_fun :: (term() -> boolean())

  @type t :: %__MODULE__{
          max_attempts: pos_integer(),
          backoff: backoff(),
          base_delay: pos_integer(),
          max_delay: pos_integer(),
          retryable?: retryable_fun()
        }

  defstruct max_attempts: 3,
            backoff: :exponential,
            base_delay: 500,
            max_delay: 10_000,
            retryable?: &__MODULE__.default_retryable?/1

  @doc """
  Creates a new retry policy.

  ## Options

    * `:max_attempts` - total attempts including the first (default: 3)
    * `:backoff` - `:exponential`, `:linear`, or `:constant` (default: `:exponential`)
    * `:base_delay` - starting delay in ms (default: 500)
    * `:max_delay` - maximum delay cap in ms (default: 10_000)
    * `:retryable?` - function that takes an error and returns whether to retry (default: connection errors only)

  """
  @spec new(keyword()) :: t()
  def new(opts \\ []) do
    struct!(__MODULE__, opts)
  end

  @doc """
  Calculates the delay for a given attempt number (0-based).
  """
  @spec delay(t(), non_neg_integer()) :: non_neg_integer()
  def delay(%__MODULE__{} = policy, attempt) do
    raw =
      case policy.backoff do
        :exponential ->
          policy.base_delay * Integer.pow(2, attempt)

        :linear ->
          policy.base_delay * (attempt + 1)

        :constant ->
          policy.base_delay
      end

    min(raw, policy.max_delay)
  end

  @doc """
  Default retryable check. Retries on connection-related errors,
  not on validation or command errors.
  """
  @spec default_retryable?(term()) :: boolean()
  def default_retryable?(:timeout), do: true
  def default_retryable?({_stdout, exit_code}) when exit_code in [125, 126, 127], do: true
  def default_retryable?(_), do: false
end
