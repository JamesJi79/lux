defmodule Lux.Rust.Component do
  @moduledoc "Rust component definition support for native code execution."
  use Rustler, otp_app: :lux, crate: "lux_rust"

  def process(%{name: name, inputs: inputs, logic: _logic} = component, ctx \\ %{}) do
    case component[:type] do
      "transform" -> transform_data(name, Jason.encode!(inputs), Jason.encode!(ctx))
      "validate" -> validate_data(name, Jason.encode!(inputs), Jason.encode!(ctx))
      "compute" -> compute_value(name, Jason.encode!(inputs), Jason.encode!(ctx))
      _ -> {:error, "Unknown component type: #{component[:type]}"}
    end
  end

  defp transform_data(_name, _inputs, _ctx), do: {:error, "Rust NIF not compiled"}
  defp validate_data(_name, _inputs, _ctx), do: {:error, "Rust NIF not compiled"}
  defp compute_value(_name, _inputs, _ctx), do: {:error, "Rust NIF not compiled"}
end