defmodule Docker.Debug.RetryTest do
  use ExUnit.Case

  alias Docker.Debug.Retry

  describe "new/1" do
    test "defaults" do
      policy = Retry.new()
      assert policy.max_attempts == 3
      assert policy.backoff == :exponential
      assert policy.base_delay == 500
      assert policy.max_delay == 10_000
    end

    test "custom options" do
      policy = Retry.new(max_attempts: 5, backoff: :linear, base_delay: 1_000)
      assert policy.max_attempts == 5
      assert policy.backoff == :linear
      assert policy.base_delay == 1_000
    end
  end

  describe "delay/2" do
    test "exponential backoff" do
      policy = Retry.new(base_delay: 100, max_delay: 10_000)
      assert Retry.delay(policy, 0) == 100
      assert Retry.delay(policy, 1) == 200
      assert Retry.delay(policy, 2) == 400
      assert Retry.delay(policy, 3) == 800
    end

    test "linear backoff" do
      policy = Retry.new(backoff: :linear, base_delay: 100)
      assert Retry.delay(policy, 0) == 100
      assert Retry.delay(policy, 1) == 200
      assert Retry.delay(policy, 2) == 300
    end

    test "constant backoff" do
      policy = Retry.new(backoff: :constant, base_delay: 500)
      assert Retry.delay(policy, 0) == 500
      assert Retry.delay(policy, 1) == 500
      assert Retry.delay(policy, 5) == 500
    end

    test "respects max_delay" do
      policy = Retry.new(base_delay: 1_000, max_delay: 2_000)
      assert Retry.delay(policy, 0) == 1_000
      assert Retry.delay(policy, 1) == 2_000
      assert Retry.delay(policy, 10) == 2_000
    end
  end

  describe "default_retryable?/1" do
    test "timeout is retryable" do
      assert Retry.default_retryable?(:timeout) == true
    end

    test "exit code 125 is retryable" do
      assert Retry.default_retryable?({"error", 125}) == true
    end

    test "exit code 126 is retryable" do
      assert Retry.default_retryable?({"error", 126}) == true
    end

    test "exit code 127 is retryable" do
      assert Retry.default_retryable?({"error", 127}) == true
    end

    test "exit code 1 is not retryable" do
      assert Retry.default_retryable?({"error", 1}) == false
    end

    test "other errors are not retryable" do
      assert Retry.default_retryable?(:something_else) == false
    end
  end
end
