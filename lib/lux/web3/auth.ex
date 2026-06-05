defmodule Lux.Web3.Auth do
  @moduledoc "Web3 authentication via EIP-4361 (Sign-in with Ethereum) with role-based access control."
  
  def verify_signature(message, signature, address) do
    case ExKeccak.recover(signature, ExKeccak.hash_256(message)) do
      {:ok, recovered} ->
        if String.downcase(recovered) == String.downcase(address),
          do: {:ok, %{verified: true, address: address}},
          else: {:error, "Signature does not match address"}
      {:error, reason} ->
        {:error, "Signature recovery failed: #{inspect(reason)}"}
      _ ->
        {:error, "Unexpected signature recovery result"}
    end
  end
  
  def verify_siwe(message, signature, address) do
    prefix = message <> "\n" <> address
    verify_signature(prefix, signature, address)
  end
  
  def generate_challenge(address, nonce) do
    now = DateTime.utc_now() |> DateTime.to_iso8601()
    "localhost:4000 wants you to sign in with your Ethereum account:\n" <>
    address <> "\n\nSign in with Ethereum to the app.\n\nURI: http://localhost:4000\nVersion: 1\nChain ID: 1\nNonce: " <>
    nonce <> "\nIssued At: " <> now
  end
  
  def authorize(action, user_roles, required_roles) do
    has_role = Enum.any?(required_roles, fn r -> r in user_roles end)
    if has_role, do: {:ok, :authorized}, else: {:error, :forbidden}
  end
end
