defmodule Lux.Web3.GasTest do
  use ExUnit.Case, async: true
  import Lux.Web3.Gas

  describe "hex_to_int/1" do
    test "parses 0x0 as zero" do
      assert hex_to_int("0x0") == 0
    end

    test "parses 0x5208 as 21000" do
      assert hex_to_int("0x5208") == 21000
    end

    test "parses large hex values" do
      assert hex_to_int("0x0de0b6b3a7640000") == 1_000_000_000_000_000_000
    end
  end
end
