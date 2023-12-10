defmodule ImplGameTest do
  use ExUnit.Case
  alias Impl.Game

  test "new game returns structure" do
    game = Game.new_game()

    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert length(game.letters) > 0
  end

  test "new game returns correct word" do
    game = Game.new_game("golf")

    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert game.letters == ["g", "o", "l", "f"]
  end

  test "state doesn't change if game is won or lost" do
    for state <- [:won, :lost] do
      game = Game.new_game("golf")
      game = Map.put(game, :game_state, state)
      {new_game, _tally} = Game.make_move(game, "x")
      assert new_game === game
    end
  end

  test "game reports duplicate guesses" do
    game = Game.new_game()
    {game, _tally} = Game.make_move(game, "x")
    assert game.game_state != :already_used
    {game, _tally} = Game.make_move(game, "y")
    assert game.game_state != :already_used
    {game, _tally} = Game.make_move(game, "x")
    assert game.game_state == :already_used
  end

  test "we record letters used" do
    game = Game.new_game()
    {game, _tally} = Game.make_move(game, "x")
    {game, _tally} = Game.make_move(game, "y")
    {game, _tally} = Game.make_move(game, "x")
    assert MapSet.equal?(game.used, MapSet.new(["x", "y"]))
  end

  test "we recognize letters in the word" do
    game = Game.new_game("golf")
    {game, _tally} = Game.make_move(game, "g")
    assert game.game_state == :good_guess
    {game, _tally} = Game.make_move(game, "g")
    assert game.game_state == :already_used
    {game, _tally} = Game.make_move(game, "o")
    assert game.game_state == :good_guess
  end

  test "we recognize when game is won" do
    game = Game.new_game("golf")
    {game, _tally} = Game.make_move(game, "g")
    {game, _tally} = Game.make_move(game, "o")
    {game, _tally} = Game.make_move(game, "l")
    assert game.game_state != :won
    {game, _tally} = Game.make_move(game, "f")
    assert game.game_state == :won
  end

  test "we recognize letters not in the word" do
    game = Game.new_game("golf")
    {game, _tally} = Game.make_move(game, "x")
    assert game.game_state == :bad_guess
    {game, _tally} = Game.make_move(game, "g")
    assert game.game_state == :good_guess
    {game, _tally} = Game.make_move(game, "a")
    assert game.game_state == :bad_guess
  end

  test "we recognize when game is lost" do
    game = Game.new_game("golf")
    {game, _tally} = Game.make_move(game, "a")
    {game, _tally} = Game.make_move(game, "b")
    {game, _tally} = Game.make_move(game, "c")
    {game, _tally} = Game.make_move(game, "d")
    {game, _tally} = Game.make_move(game, "e")
    {game, _tally} = Game.make_move(game, "h")
    assert game.game_state != :lost
    {game, _tally} = Game.make_move(game, "r")
    assert game.game_state == :lost
  end

  test "can handle a sequence of moves" do
    # hello
    [
      # guess a
      ["a", :bad_guess, 6, ["_", "_", "_", "_", "_"], ["a"]],
      # guess a again
      ["a", :already_used, 6, ["_", "_", "_", "_", "_"], ["a"]],
      # guess e
      ["e", :good_guess, 6, ["_", "e", "_", "_", "_"], ["a", "e"]],
      # guess x
      ["x", :bad_guess, 5, ["_", "e", "_", "_", "_"], ["a", "e", "x"]]
    ]
    |> test_sequence_of_moves()
  end

  def test_sequence_of_moves(script) do
    game = Game.new_game("hello")
    Enum.reduce(script, game, &check_one_move/2)
  end

  def check_one_move(script_row, game) do
    [
      guess,
      expected_state,
      expected_turns_left,
      expected_letters,
      expected_used
    ] = script_row

    {game, tally} = Game.make_move(game, guess)
    assert tally.game_state == expected_state
    assert tally.turns_left == expected_turns_left
    assert tally.letters == expected_letters
    assert tally.used == expected_used
    game
  end
end
