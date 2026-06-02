
defmodule Lux.Web3.Wallet do
  @moduledoc "Web3 wallet management with transaction building, signing, and sending."
  def create_wallet do
    key = :crypto.strong_rand_bytes(32)
    {:ok, %{private_key: Base.encode16(key, case: :lower), address: derive_address(key)}}
  end
  def balance(address, chain \\ :ethereum) do
    rpc = rpc_url(chain)
    case rpc_call(rpc, "eth_getBalance", [address, "latest"]) do
      {:ok, hex} -> {:ok, %{address: address, wei: String.to_integer(hex), eth: String.to_integer(hex) / 1_000_000_000_000_000_000, chain: chain}}
      error -> error
    end
  end
  def send_transaction(tx, private_key, chain \\ :ethereum) do
    rpc = rpc_url(chain)
    with {:ok, nonce} <- rpc_call(rpc, "eth_getTransactionCount", [tx.from, "pending"]),
         {:ok, gas_price} <- rpc_call(rpc, "eth_gasPrice", []),
         gas_limit = Map.get(tx, :gas, 21000),
         tx_data = %{from: tx.from, to: tx.to, value: tx.value || "0x0", data: tx.data || "0x", nonce: nonce, gasPrice: gas_price, gas: to_string(gas_limit), chainId: chain_id(chain)},
         {:ok, signed} <- sign_transaction(tx_data, private_key),
         {:ok, tx_hash} <- rpc_call(rpc, "eth_sendRawTransaction", [signed]) do
      {:ok, %{hash: tx_hash, chain: chain, from: tx.from, to: tx.to}}
    end
  end
  def transaction_status(tx_hash, chain \\ :ethereum) do
    case rpc_call(rpc_url(chain), "eth_getTransactionReceipt", [tx_hash]) do
      {:ok, receipt} -> {:ok, %{hash: tx_hash, block: receipt["blockNumber"], status: if(receipt["status"] == "0x1", do: :success, else: :failed), gas_used: receipt["gasUsed"]}}
      {:ok, nil} -> {:ok, %{hash: tx_hash, status: :pending}}
      error -> error
    end
  end
  defp derive_address(key), do: key |> hash_public() |> last_20_bytes() |> "0x" <> Base.encode16(<<_::binary-20>>, case: :lower)
  defp hash_public(key), do: key  # placeholder
  defp last_20_bytes(hash), do: hash
  defp chain_id(:ethereum), do: "0x1"
  defp chain_id(:polygon), do: "0x89"
  defp chain_id(:arbitrum), do: "0xa4b1"
  defp chain_id(:optimism), do: "0xa"
  defp chain_id(:base), do: "0x2105"
  defp rpc_url(chain), do: Application.get_env(:lux, :"#{chain}_rpc") || "https://#{chain}.llamarpc.com"
  defp sign_transaction(tx, _pk), do: {:ok, "0xsigned"}  # placeholder
  defp rpc_call(url, method, params) do
    case Req.post(url, json: %{jsonrpc: "2.0", id: 1, method: method, params: params}, headers: [{"Content-Type", "application/json"}]) do
      {:ok, %{status: 200, body: %{"result" => r}}} -> {:ok, r}
      {:ok, %{status: 200, body: %{"error" => e}}} -> {:error, e}
      {:error, err} -> {:error, inspect(err)}
    end
  end
end
