
defmodule Lux.Web3.MultiChain do
  @moduledoc "Multi-chain data aggregation engine supporting Ethereum, Polygon, Arbitrum, and Optimism."
  @chains %{
    ethereum: %{name: "Ethereum", rpc: "https://eth.llamarpc.com", native: "ETH", decimals: 18, explorer: "https://etherscan.io"},
    polygon: %{name: "Polygon", rpc: "https://polygon.llamarpc.com", native: "MATIC", decimals: 18, explorer: "https://polygonscan.com"},
    arbitrum: %{name: "Arbitrum", rpc: "https://arbitrum.llamarpc.com", native: "ETH", decimals: 18, explorer: "https://arbiscan.io"},
    optimism: %{name: "Optimism", rpc: "https://optimism.llamarpc.com", native: "ETH", decimals: 18, explorer: "https://optimistic.etherscan.io"},
    base: %{name: "Base", rpc: "https://base.llamarpc.com", native: "ETH", decimals: 18, explorer: "https://basescan.org"}
  }
  def chains, do: @chains
  def chain_info(key), do: Map.get(@chains, key)
  def balance(address, chain \\ :ethereum) do
    rpc = @chains[chain][:rpc]
    case rpc_call(rpc, "eth_getBalance", [address, "latest"]) do
      {:ok, hex} -> {:ok, %{chain: chain, address: address, wei: String.to_integer(hex), eth: String.to_integer(hex) / 1_000_000_000_000_000_000}}
      error -> error
    end
  end
  def multi_chain_balance(address) do
    Enum.reduce(@chains, {:ok, %{}}, fn {key, %{rpc: rpc}}, {:ok, acc} ->
      case rpc_call(rpc, "eth_getBalance", [address, "latest"]) do
        {:ok, hex} -> {:ok, Map.put(acc, key, %{wei: String.to_integer(hex), eth: String.to_integer(hex) / 1_000_000_000_000_000_000})}
        {:error, _} -> {:ok, Map.put(acc, key, %{error: "RPC failed"})}
      end
    end)
  end
  def token_balance(contract, address, chain \\ :ethereum) do
    data = "0x70a08231" <> String.slice(address, 2..-1) |> String.pad_leading(64, "0")
    rpc = @chains[chain][:rpc]
    case rpc_call(rpc, "eth_call", [%{to: contract, data: data}, "latest"]) do
      {:ok, hex} -> {:ok, %{chain: chain, contract: contract, address: address, wei: String.to_integer(hex)}}
      error -> error
    end
  end
  defp rpc_call(url, method, params) do
    case Req.post(url, json: %{jsonrpc: "2.0", id: 1, method: method, params: params}, headers: [{"Content-Type", "application/json"}]) do
      {:ok, %{status: 200, body: %{"result" => r}}} -> {:ok, r}
      {:ok, %{status: 200, body: %{"error" => e}}} -> {:error, e}
      {:error, err} -> {:error, inspect(err)}
    end
  end
end
