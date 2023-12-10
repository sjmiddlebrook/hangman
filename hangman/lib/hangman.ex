defmodule Hangman do
  alias Impl.Game
  alias Hangman.Type

  @type state :: Type.state()
  @opaque game :: Game.t()
  @type tally :: Type.tally()

  @spec new_game() :: game
  defdelegate new_game(), to: Game

  @spec make_move(game, String.t()) :: {game, tally}
  defdelegate make_move(game, guess), to: Game
end