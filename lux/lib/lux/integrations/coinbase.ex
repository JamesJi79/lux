
defmodule Lux.Integrations.Coinbase do
  @moduledoc """
  Coinbase exchange integration for spot trading and market data.
  Uses Coinbase Advanced Trade API (v3).
  """
  @base_url "https://api.coinbase.com"
  @api_url "https://api.exchange.coinbase.com"

  # Public endpoints
  def ticker(product_id), do: get("/api/v3/brokerage/market/productbook", %{product_id: product_id, limit: 1})
  def order_book(product_id, limit \\ 100), do: get_cex("/products/#{product_id}/book", %{level: if(limit > 50, do: 2, else: 1)})
  def trades(product_id, limit \\ 100), do: get_cex("/products/#{product_id}/trades", %{limit: limit})
  def products, do: get_cex("/products", %{})

  # Authenticated endpoints
  def accounts, do: signed_get("/api/v3/brokerage/accounts", %{})
  def orders, do: signed_get("/api/v3/brokerage/orders/historical/batch", %{})

  def market_buy(product_id, funds) do
    signed_post("/api/v3/brokerage/orders", %{
      client_order_id: UUID.uuid4(), product_id: product_id,
      side: "BUY", order_configuration: %{market_market_ioc: %{quote_size: to_string(funds)}}
    })
  end

  def market_sell(product_id, size) do
    signed_post("/api/v3/brokerage/orders", %{
      client_order_id: UUID.uuid4(), product_id: product_id,
      side: "SELL", order_configuration: %{market_market_ioc: %{base_size: to_string(size)}}
    })
  end

  defp get(path, params), do: request(:get, path, params, false, false)
  defp get_cex(path, params), do: request(:get, path, params, false, true)
  defp signed_get(path, params), do: request(:get, path, params, true, false)
  defp signed_post(path, params), do: request(:post, path, params, true, false)

  defp request(method, path, params, signed, cex) do
    base = if cex, do: @api_url, else: @base_url
    url = base <> path <> (if params != %{}, do: "?" <> URI.encode_query(params), else: "")

    req = Req.new(url: url, headers: [{"Content-Type", "application/json"}])

    req = if signed do
      ts = DateTime.utc_now() |> DateTime.to_unix()
      q = URI.encode_query(params)
      payload = "#{ts}#{method |> to_string() |> String.upcase()}#{path}#{q}"
      sig = :crypto.hmac(:sha256, api_secret(), payload) |> Base.encode16(case: :lower)
      req
      |> Req.put_header("CB-ACCESS-KEY", api_key())
      |> Req.put_header("CB-ACCESS-SIGN", sig)
      |> Req.put_header("CB-ACCESS-TIMESTAMP", to_string(ts))
      |> Req.put_header("CB-ACCESS-PASSPHRASE", api_passphrase())
    else, do: req

    case Req.request(req, method: method) do
      {:ok, %{status: 200, body: b}} -> {:ok, b}
      {:ok, %{status: s, body: b}} -> {:error, {s, b["message"] || inspect(b)}}
      {:error, e} -> {:error, inspect(e)}
    end
  end

  defp api_key, do: Application.get_env(:lux, Lux.Integrations.Coinbase)[:api_key]
  defp api_secret, do: Application.get_env(:lux, Lux.Integrations.Coinbase)[:api_secret]
  defp api_passphrase, do: Application.get_env(:lux, Lux.Integrations.Coinbase)[:api_passphrase]
end
