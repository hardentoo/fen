module Castling where
import Data.Set (Set)
import Data.Maybe (catMaybes)
import Data.Set (Set, fromList)

import Control.Applicative ((<$>), (<*>))

import Square (Square(Square))
import Color (Color(White, Black))


data Side = Queenside | Kingside
            deriving (Show, Eq, Ord)

data CastlingRight = Castling { side :: Side, clr :: Color }
                     deriving (Show, Eq, Ord)

associated :: Square -> Set CastlingRight
associated (Square f r) = fromList $
  Castling <$> associatedSides f <*> catMaybes [associatedColor r]

associatedColor :: Int -> Maybe Color
associatedColor 1 = Just White
associatedColor 8 = Just Black
associatedColor _ = Nothing

associatedSides :: Char -> [Side]
associatedSides 'a' = [Queenside]
associatedSides 'h' = [Kingside]
associatedSides 'e' = [Kingside, Queenside]
associatedSides _ = []
