
defmodule Lux.Web3.Gas do
  @moduledoc "Gas optimization and transaction management for EVM chains."
  def estimate_gas(to, data, chain \\ :ethereum) do
    rpc = rpc_url(chain)
    params = [%{to: to, data: data}, "latest"]
    case json_rpc(rpc, "eth_estimateGas", params) do
      {:ok, result} -> {:ok, %{gas: String.to_integer(result), chain: chain}}
      error -> error
    end
  end
  def gas_price(chain \\ :ethereum) do
    case json_rpc(rpc_url(chain), "eth_gasPrice", []) do
      {:ok, result} -> {:ok, %{wei: String.to_integer(result), gwei: String.to_integer(result) / 1_000_000_000, chain: chain}}
      error -> error
    end
  end
  def optimize_gas(to, data, max_gas, chain \\ :ethereum) do
    with {:ok, %{gas: estimated}} <- estimate_gas(to, data, chain),
         {:ok, %{gwei: price}} <- gas_price(chain) do
      if estimated <= max_gas,
        do: {:ok, %{estimated: estimated, price_gwei: price, total_eth: estimated * price / 1_000_000_000, feasible: true}},
        else: {:ok, %{estimated: estimated, price_gwei: price, feasible: false, overshoot: estimated - max_gas}}
    end
  end
  defp rpc_url(:ethereum), do: Application.get_env(:lux, :ethereum_rpc) || "https://eth.llamarpc.com"
  defp rpc_url(:polygon), do: Application.get_env(:lux, :polygon_rpc) || "https://polygon.llamarpc.com"
  defp rpc_url(:arbitrum), do: Application.get_env(:lux, :arbitrum_rpc) || "https://arbitrum.llamarpc.com"
  defp json_rpc(url, method, params) do
    body = %{jsonrpc: "2.0", id: 1, method: method, params: params}
    case Req.post(url, json: body, headers: [{"Content-Type", "application/json"}]) do
      {:ok, %{status: 200, body: %{"result" => r}}} -> {:ok, r}
      {:ok, %{status: 200, body: %{"error" => e}}} -> {:error, e}
      {:error, err} -> {:error, inspect(err)}
    end
  end
end
