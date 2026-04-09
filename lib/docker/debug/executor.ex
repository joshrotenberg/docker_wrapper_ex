defmodule Docker.Debug.Executor do
  @moduledoc """
  Retry-aware command executor with dry-run and verbose logging support.

  Wraps `Docker.Command.run/3` with debug capabilities.
  """

  require Logger

  alias Docker.Config, as: DockerConfig
  alias Docker.Debug.{Config, Retry}

  @doc """
  Executes a command with debug options applied.

  When `dry_run: true`, returns the command string that would be executed.
  When `verbose: true`, logs the command and result.
  When `retry` is set, retries failed commands according to the policy.
  """
  @spec run(module(), struct(), DockerConfig.t(), Config.t()) ::
          {:ok, term()} | {:error, term()}
  def run(mod, command, config, %Config{dry_run: true}) do
    args = DockerConfig.base_args(config) ++ mod.args(command)
    {:ok, Enum.join([config.binary | args], " ")}
  end

  def run(mod, command, config, %Config{} = debug) do
    log_command(mod, command, config, debug.verbose)
    result = execute_with_retry(mod, command, config, debug.retry, debug.verbose)
    log_result(result, debug.verbose)
    result
  end

  defp log_command(mod, command, config, true) do
    args = DockerConfig.base_args(config) ++ mod.args(command)
    Logger.info("[docker_wrapper] executing: #{Enum.join([config.binary | args], " ")}")
  end

  defp log_command(_, _, _, _), do: :ok

  defp log_result({:ok, val}, true) do
    Logger.info("[docker_wrapper] success: #{inspect(val, limit: 200)}")
  end

  defp log_result({:error, reason}, true) do
    Logger.warning("[docker_wrapper] failed: #{inspect(reason, limit: 200)}")
  end

  defp log_result(_, _), do: :ok

  defp execute_with_retry(mod, command, config, nil, _verbose) do
    Docker.Command.run(mod, command, config)
  end

  defp execute_with_retry(mod, command, config, %Retry{} = policy, verbose) do
    do_retry(mod, command, config, policy, 0, verbose, nil)
  end

  defp do_retry(_mod, _command, _config, %Retry{max_attempts: max}, attempt, _verbose, last_error)
       when attempt >= max do
    {:error, last_error}
  end

  defp do_retry(mod, command, config, %Retry{} = policy, attempt, verbose, _last_error) do
    maybe_sleep(policy, attempt, verbose)

    case Docker.Command.run(mod, command, config) do
      {:ok, _} = success ->
        success

      {:error, reason} = error ->
        if policy.retryable?.(reason) do
          do_retry(mod, command, config, policy, attempt + 1, verbose, reason)
        else
          error
        end
    end
  end

  defp maybe_sleep(_policy, 0, _verbose), do: :ok

  defp maybe_sleep(policy, attempt, verbose) do
    delay = Retry.delay(policy, attempt - 1)

    if verbose do
      Logger.info("[docker_wrapper] retry #{attempt}/#{policy.max_attempts - 1} after #{delay}ms")
    end

    Process.sleep(delay)
  end
end
