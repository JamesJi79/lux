defmodule Lux.Rust.Cargo do
  @moduledoc "Cargo package management integration for Rust dependency handling."
  use Rustler, otp_app: :lux, crate: "lux_rust"

  def add_dependency(name, version \\ "*") do
    case resolve_crate(name, version) do
      {:ok, info} -> add_to_project(Jason.encode!(info))
      error -> error
    end
  end

  def list_dependencies do
    case read_cargo_toml() do
      {:ok, content} -> parse_dependencies(content)
      error -> error
    end
  end

  defp resolve_crate(_name, _version), do: {:ok, %{name: _name, version: _version}}
  defp add_to_project(_info), do: {:error, "Rust NIF not compiled"}
  defp read_cargo_toml, do: {:error, "Rust NIF not compiled"}
  defp parse_dependencies(_content), do: {:error, "Rust NIF not compiled"}
end