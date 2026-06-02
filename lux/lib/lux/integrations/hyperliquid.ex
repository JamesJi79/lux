defmodule Lux.Integrations.Hyperliquid do
  @moduledoc "Hyperliquid DEX integration for perpetual trading."
  @base_url "https://api.hyperliquid.xyz"
  @info_url "https://api.hyperliquid.xyz/info"
  def metadata, do: get_info("/meta")
  def all_mids, do: get_info("/allMids")
  def orderbook(coin), do: post_info("/l2Book", %{"coin" => coin})
  def recent_trades(coin), do: post_info("/trades", %{"coin" => coin})
  def candle_snapshot(coin, interval, limit \\ 100), do: post_info("/candleSnapshot", %{"coin" => coin, "interval" => interval, "limit" => limit})
  defp get_info(path), do: req(:get, @info_url <> path, %{}, false)
  defp post_info(path, body), do: req(:post, @info_url <> path, body, false)
  defp req(method, url, body, signed) do
    opts = [url: url, headers: [{"Content-Type", "application/json"}]]
    req = Req.new(opts)
    case Req.request(req, method: method, json: body) do
      {:ok, %{status: 200, body: b}} -> {:ok, b}
      {:ok, %{status: s, body: b}} -> {:error, {s, b}}
      {:error, e} -> {:error, inspect(e)}
    end
  end
end