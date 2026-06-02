defmodule Lux.Rust.Test do
  @moduledoc "Rust testing framework integration for native test execution."
  use Rustler, otp_app: :lux, crate: "lux_rust"

  def run_tests(test_suite, config \\ %{}) do
    case test_suite[:type] do
      "unit" -> run_unit_tests(Jason.encode!(test_suite), Jason.encode!(config))
      "integration" -> run_integration_tests(Jason.encode!(test_suite), Jason.encode!(config))
      "benchmark" -> run_benchmarks(Jason.encode!(test_suite), Jason.encode!(config))
      _ -> {:error, "Unknown test type: #{test_suite[:type]}"}
    end
  end

  defp run_unit_tests(_suite, _config), do: {:error, "Rust NIF not compiled"}
  defp run_integration_tests(_suite, _config), do: {:error, "Rust NIF not compiled"}
  defp run_benchmarks(_suite, _config), do: {:error, "Rust NIF not compiled"}
end