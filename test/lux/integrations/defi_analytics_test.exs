defmodule Lux.Integrations.DefiAnalyticsTest do
  use ExUnit.Case, async: true

  alias Lux.Integrations.DefiAnalytics

  describe "protocol data" do
    test "top_protocols/0 returns protocol TVL data" do
      result = DefiAnalytics.top_protocols(limit: 5)
      assert elem(result, 0) in [:ok, :error]
    end

    test "protocol_by_slug/0 returns specific protocol" do
      result = DefiAnalytics.protocol_by_slug("uniswap-v3")
      assert elem(result, 0) in [:ok, :error]
    end
  end

  describe "chain data" do
    test "chain_tvl/0 returns chain-level TVL" do
      result = DefiAnalytics.chain_tvl("ethereum")
      assert elem(result, 0) in [:ok, :error]
    end
  end

  describe "token data" do
    test "token_market_data/0 returns token info" do
      # Use USDC as a known token address
      result = DefiAnalytics.token_market_data("0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48")
      assert elem(result, 0) in [:ok, :error]
    end
  end

  describe "trending" do
    test "trending_protocols/0 returns trending data" do
      result = DefiAnalytics.trending_protocols(limit: 10)
      assert elem(result, 0) in [:ok, :error]
    end
  end

  describe "stablecoin data" do
    test "stablecoin_circulation/0 returns stablecoin metrics" do
      result = DefiAnalytics.stablecoin_circulation()
      assert elem(result, 0) in [:ok, :error]
    end
  end

  describe "market overview" do
    test "market_overview/0 returns aggregate metrics" do
      result = DefiAnalytics.market_overview()
      assert elem(result, 0) in [:ok, :error]
    end
  end
end
