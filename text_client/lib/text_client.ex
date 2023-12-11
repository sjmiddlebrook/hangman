defmodule TextClient do
  @spec start() :: :ok
  defdelegate start, to: Impl.Player
end
