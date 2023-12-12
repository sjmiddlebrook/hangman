defmodule Hangman.Impl.Game do
  alias Hangman.Type

  @type t :: %__MODULE__{
          turns_left: integer,
          game_state: Type.state(),
          letters: list(String.t()),
          used: MapSet.t(String.t())
        }
  defstruct(
    turns_left: 7,
    game_state: :initializing,
    letters: [],
    used: MapSet.new()
  )

  ##########################################################

  @spec new_game() :: t
  def new_game do
    Dictionary.random_word()
    |> new_game()
  end

  @spec new_game(String.t()) :: t
  def new_game(word) do
    %__MODULE__{
      letters: word |> String.codepoints()
    }
  end

  ##########################################################

  @spec make_move(t, String.t()) :: {t, Type.tally()}
  def make_move(game = %{game_state: state}, _guess)
      when state in [:won, :lost] do
    game |> return_with_tally()
  end

  def make_move(game, guess) do
    is_already_guessed = MapSet.member?(game.used, guess)

    accept_guess(game, guess, is_already_guessed)
    |> return_with_tally()
  end

  ##########################################################

  defp accept_guess(game, _guess, _is_already_guessed = true) do
    %{game | game_state: :already_used}
  end

  defp accept_guess(game, guess, _is_already_guessed) do
    %{game | used: MapSet.put(game.used, guess)}
    |> score_guess(Enum.member?(game.letters, guess))
  end

  ##########################################################

  defp score_guess(game, _is_good_guess = true) do
    new_state = maybe_won(MapSet.subset?(MapSet.new(game.letters), game.used))
    %{game | game_state: new_state}
  end

  defp score_guess(game = %{turns_left: 1}, _is_good_guess) do
    %{game | game_state: :lost, turns_left: 0}
  end

  defp score_guess(game, _is_good_guess) do
    %{game | game_state: :bad_guess, turns_left: game.turns_left - 1}
  end

  defp maybe_won(_is_every_letter_used = true) do
    :won
  end

  defp maybe_won(_is_every_letter_used) do
    :good_guess
  end

  ##########################################################

  defp reveal_guessed_letters(game = %{game_state: :lost}) do
    game.letters
  end

  defp reveal_guessed_letters(game) do
    Enum.map(game.letters, &maybe_reveal_letter(&1, MapSet.member?(game.used, &1)))
  end

  defp maybe_reveal_letter(letter, _is_letter_guessed = true) do
    letter
  end

  defp maybe_reveal_letter(_letter, _is_letter_guessed) do
    "_"
  end

  defp return_with_tally(game) do
    {game, tally(game)}
  end

  def tally(game) do
    %{
      turns_left: game.turns_left,
      game_state: game.game_state,
      letters: reveal_guessed_letters(game),
      used: game.used |> MapSet.to_list() |> Enum.sort()
    }
  end
end
