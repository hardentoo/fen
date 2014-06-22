module Position where
import Prelude (flip, (.), Int, Eq, Show)
import Data.Bool (Bool)
import Data.Maybe (Maybe, isNothing)
import qualified Data.Map as Map
import qualified Data.Set as Set

import Square (Square)
import Piece (Piece)
import Color (Color, toggle, lastRank)
import Move (Move(Move), Promotion)
import Piece (pieceType, color)
import Castling (CastlingRight)

type Board = Map.Map Square Piece

data Position = Position { board :: Board,
                           passant :: Maybe Square,
                           halfMoveNr :: Int,
                           fullMoveNr :: Int,
                           turn :: Color,
                           castling :: Set.Set CastlingRight }
                           deriving (Show, Eq)



lastRank :: Position -> Int
lastRank = Color.lastRank. turn

nextTurn :: Position -> Position
nextTurn p = p{turn = enemyColor p }

enemyColor :: Position -> Color
enemyColor = Color.toggle. turn

lookup :: Square -> Position -> Maybe Piece
lookup sq = Map.lookup sq. board

isEmpty :: Position -> Square -> Bool
isEmpty p sq = isNothing (lookup sq p)
