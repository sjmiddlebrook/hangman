defmodule DictionaryTest do
  use ExUnit.Case
  doctest Dictionary

  test "random word returns a word" do
    assert String.length(Dictionary.random_word()) > 1
  end
end
