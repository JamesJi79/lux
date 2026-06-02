
defmodule Lux.Rust do
  @moduledoc """
  Rust native code integration for high-performance operations via NIF bindings.
  Built with Rustler - safe, efficient FFI between Elixir and Rust.
  """

  @doc """
  Returns the Rust NIF library version.
  """
  def version, do: nif_version() || "unavailable"

  @doc """
  Tests connectivity by pinging the Rust runtime.
  """
  def ping, do: nif_ping() || "no_rust"

  @doc """
  Adds two integers using Rust native code.
  """
  def add(a, b), do: nif_add(a, b) || a + b

  # Load NIF - gracefully handle if compiled
  use Rustler, otp_app: :lux, crate: "lux_rust"

  # Fallbacks when NIF is not compiled
  defp nif_version(_), do: nil
  defp nif_ping(_), do: nil
  defp nif_add(_, _), do: nil
end
