module MowMowMow where

import Test.QuickCheck

-- author sofiane

data Direction = NORTH | EAST | SOUTH | WEST deriving (Eq, Ord, Show, Bounded, Enum)

left :: Direction -> Direction
left NORTH = WEST
left direction = pred direction

right :: Direction -> Direction
right WEST = NORTH
right direction = succ direction

data Lawn = Lawn { max_x :: Int, max_y :: Int } deriving (Eq, Show)
data Position = Position { x :: Int, y :: Int, direction :: Direction } deriving (Eq, Show)
data Mower = Mower { lawn :: Lawn, position :: Position } deriving (Eq, Show)

contains_position :: Lawn -> Position -> Bool
contains_position (Lawn {max_x = lx, max_y = ly}) (Position {x = px, y = py, direction = _}) = (lx >= px && ly >= py && px >= 0 && py >= 0)

data Move = LEFT | RIGHT | FORWARD deriving (Eq, Ord, Show, Bounded, Enum)

update_position_ :: Position -> Direction -> Position
update_position_ (Position {x = px, y = py, direction = dir}) NORTH = Position px (py + 1) dir
update_position_ (Position {x = px, y = py, direction = dir}) WEST = Position (px - 1) py dir
update_position_ (Position {x = px, y = py, direction = dir}) EAST = Position (px + 1) py dir
update_position_ (Position {x = px, y = py, direction = dir}) SOUTH = Position px (py -1) dir

update_position_in_lawn :: Lawn -> Position -> Move -> Position
update_position_in_lawn lawn position move
    | contains_position lawn new_position = new_position -- check every new position
    | otherwise = position -- don't move !
    where new_position = update_position position move

update_position :: Position -> Move -> Position
update_position (Position {x = px, y = py, direction = dir}) LEFT = Position px py (left dir)
update_position (Position {x = px, y = py, direction = dir}) RIGHT = Position px py (right dir)
update_position (Position {x = px, y = py, direction = dir}) FORWARD = update_position_ (Position px py dir) dir

move_mower_ :: Lawn -> Position -> [Move] -> Position
move_mower_ lawn position moves = foldl (update_position_in_lawn lawn) position moves

move_mower :: Mower -> [Move] -> Position
move_mower (Mower {lawn = l, position = pos}) moves = move_mower_ l pos moves

-- generate arbitrary moves
instance Arbitrary Move where
  arbitrary = do
    n <- choose (0,2) :: Gen Int
    return $ case n of
      0 -> LEFT
      1 -> RIGHT
      2 -> FORWARD

-- here we define our properties that the function move_mower should satisfy
-- property one -> we should always have final position in the lawn
prop_position :: [Move] -> Bool
prop_position moves =
    contains_position (Lawn 5 5) (move_mower (Mower (Lawn 5 5) (Position 3 3 EAST)) moves)

-- run : quickCheck prop_position
-- Main :: IO()
main = do
    let mower = Mower (Lawn 5 5) (Position 3 3 EAST) -- define our mower with a lawn and an initial position
    move_mower mower [FORWARD, FORWARD, RIGHT, FORWARD, FORWARD, RIGHT, FORWARD, RIGHT, RIGHT, FORWARD] -- let's move that shit !