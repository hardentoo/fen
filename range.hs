module Range (
    Range, range, range',
    pieceType,
    square, squares
    ) where

import Data.Maybe (isNothing, fromJust)
import Control.Monad ((>=>), liftM)
import Control.Applicative ((<*>), (<$>))

import MoveType (
    MoveType (Takes, Moves)
    )
import Square (
    Square,
    SquareSeries,
    up, down, left, right,
    upLeft, upRight, downLeft, downRight,
    twice,
    rank
    )
import Piece (
    OfficerType(..),
    Piece,
    PieceType(..),
    )
import Color ( 
    Color(..),
    )

data Range = Range {
    pieceType :: PieceType,
    square :: Square,
    squares :: [SquareSeries]
} deriving (Show)

range :: Color -> PieceType -> Square -> MoveType -> Range
range _ (Officer ot) s _ = officerRange ot s
range c Pawn s mt = pawnRange c s mt

range' c Pawn s = Range Pawn s (rangeMT Moves ++ rangeMT Takes)
    where rangeMT mt = squares (range c Pawn s mt)

range' c pt s = range c pt s Takes -- Takes or Moves, doesn't matter

officerRange :: OfficerType -> Square -> Range
officerRange ot s = Range (Officer ot) s $ officerSquares ot s

isJustSquare = not. isNothing

pawnRange :: Color -> Square -> MoveType -> Range
pawnRange c s mt = Range Pawn s $ pawnSquares c s mt

pawnSquares c s Moves = return. squareSequence $
    pawnSquares' c s Moves

pawnSquares c s Takes = return <$> squareSet $
    pawnSquares' c s Takes 

pawnSquares' :: Color -> Square -> MoveType -> [Maybe Square]
pawnSquares' c s mt = pawnMoves c (rank s) mt <*> [s]

officerSquares :: OfficerType -> Square -> [SquareSeries]
officerSquares ot s = squareSequence <$> officerSquaresM ot s

type Reducer = (Maybe Square -> Bool) -> [Maybe Square] -> [Maybe Square]

toSeries :: Reducer -> [Maybe Square] -> SquareSeries
toSeries r sqs = fromJust <$> r isJustSquare sqs

squareSet :: [Maybe Square] -> SquareSeries
squareSet = toSeries filter

squareSequence :: [Maybe Square] -> SquareSeries
squareSequence = toSeries takeWhile

iterateMove :: (Square -> Maybe Square) -> Square -> [Maybe Square]
iterateMove m = iterate (>>= m) . return

pawnMoves :: Color -> Int -> MoveType -> [Square -> Maybe Square]
pawnMoves White 2 Moves = [up, twice up]
pawnMoves White _ Moves = [up]
pawnMoves Black 7 Moves = [down, twice down]
pawnMoves Black _ Moves = [down]
pawnMoves White _ Takes = [upLeft, upRight]
pawnMoves Black _ Takes = [downLeft, downRight]

knightMoves = 
    [onceTwice, flip onceTwice] <*> [up, down] <*> [left, right]
    where onceTwice m m' = m' >=> twice m

officerDirections Bishop = [upLeft, upRight, downLeft, downRight]
officerDirections Rook = [up, down, left, right]
officerDirections Queen = concat $
    map officerDirections [Rook, Bishop]

officerSquaresM :: OfficerType -> Square -> [[Maybe Square]]
officerSquaresM King s = take 1 <$> officerSquaresM Queen s
officerSquaresM Knight s = liftM return (knightMoves <*> [s])
officerSquaresM ot s = drop 1. flip iterateMove s <$> officerDirections ot
    
