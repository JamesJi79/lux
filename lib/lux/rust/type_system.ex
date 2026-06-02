defmodule Lux.Rust.TypeSystem do
  @moduledoc "Rust type system and serialization for cross-language data exchange."
  use Rustler, otp_app: :lux, crate: "lux_rust"

  def serialize(value, target_type \\ "json") do
    case target_type do
      "json" -> to_json(Jason.encode!(value))
      "binary" -> to_binary(Jason.encode!(value))
      "compact" -> compact_encode(Jason.encode!(value))
      _ -> {:error, "Unknown target type: #{target_type}"}
    end
  end

  def deserialize(data, source_type \\ "json") do
    case source_type do
      "json" -> from_json(data)
      "binary" -> from_binary(data)
      "compact" -> compact_decode(data)
      _ -> {:error, "Unknown source type: #{source_type}"}
    end
  end

  defp to_json(_data), do: {:error, "Rust NIF not compiled"}
  defp to_binary(_data), do: {:error, "Rust NIF not compiled"}
  defp compact_encode(_data), do: {:error, "Rust NIF not compiled"}
  defp from_json(_data), do: {:error, "Rust NIF not compiled"}
  defp from_binary(_data), do: {:error, "Rust NIF not compiled"}
  defp compact_decode(_data), do: {:error, "Rust NIF not compiled"}
end