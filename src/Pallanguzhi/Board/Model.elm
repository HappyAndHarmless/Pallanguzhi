module Pallanguzhi.Board.Model exposing (..)

import Array
import Array exposing (Array)
import Maybe
import Debug

type Player = A | B 
type alias PitLocation = Int
type alias Pit = { player : Player, seeds : Int}

type alias Model =
  { pits : Array Pit
  , storeA : Int
  , storeB : Int
  }

pitsPerPlayer : number
pitsPerPlayer = 7

seedsPerPit : number
seedsPerPit = 12

init : Model
init = 
  let 
    s = 
      seedsPerPit
    row = 
      [s, s, s, 2, s, s, s] |> Array.fromList
    makePit player seeds =
      {player = player, seeds = seeds}
    makeRow player = 
      row
      |> Array.map (makePit player) 
  in
    { pits = Array.append (makeRow A) (makeRow B)
    , storeA = 0
    , storeB = 0
    }

rows : Model -> (List Pit, List Pit)
rows model = 
  let 
    f g = Array.toList >> g pitsPerPlayer
  in 
    ( f List.take model.pits
    , f List.drop model.pits
    )

lookup : PitLocation -> Model -> Pit
lookup loc model = 
  case Array.get loc model.pits of
    Just pit -> 
      pit
    Nothing  -> 
      -- Invalid index is only possible due to programmer error.
      Debug.crash <| "error: invalid index: " ++ (toString loc)

next : PitLocation -> PitLocation
next loc =
  let 
    total = 2 * pitsPerPlayer 
  in 
    (loc + 1) % total

updateSeeds : PitLocation -> (Int -> Int) -> Model -> Model
updateSeeds loc f model =
  let 
    pit = 
      lookup loc model
    pits = 
      Array.set loc { pit | seeds = f pit.seeds } model.pits
  in
    { model | pits = pits }

inc : PitLocation -> Model -> Model
inc loc model =
  updateSeeds loc (\s -> s + 1)  model

clear : PitLocation -> Model -> Model
clear loc model =
  updateSeeds loc (always 0) model

store : Player -> Int -> Model -> Model
store player seeds model =
  case player of
    A -> { model | storeA = model.storeA + seeds }
    B -> { model | storeB = model.storeB + seeds }

capture : Player -> PitLocation -> Model -> Model
capture player loc model = 
  let 
    c = lookup loc model |> .seeds
  in
    model |> clear loc |> store player c 

otherPlayer : Player -> Player
otherPlayer player =
  case player of 
    A -> B
    B -> A

