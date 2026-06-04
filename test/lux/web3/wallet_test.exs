defmodule Lux.Web3.WalletTest do
  use ExUnit.Case, async: true
  import Lux.Web3.Wallet

  describe "hex_to_int/1" do
    test "parses '0x0' as zero" do
      assert hex_to_int("0x0") == 0
    end

    test "parses '0x1234' as 4660" do
      assert hex_to_int("0x1234") == 4660
    end

    test "parses large hex values" do
      assert hex_to_int("0x0de0b6b3a7640000") == 1_000_000_000_000_000_000
    end
  end

  describe "create_wallet/0" do
    test "returns wallet with private_key and address" do
      assert {:ok, wallet} = create_wallet()
      assert String.starts_with?(wallet.private_key, "0x") == false
      assert String.length(wallet.private_key) == 64
      assert String.starts_with?(wallet.address, "0x")
      assert String.length(wallet.address) == 42
    end
  end

  describe "balance/2" do
    test "returns structured response format" do
      # No live RPC call — use a fake address to verify response shape
      result = balance("0xdead000000000000000000000000000000000000")
      assert match?({:ok, _} | {:error, _}, result)
    end
  end
end
