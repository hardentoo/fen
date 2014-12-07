module PositionReader where
import Prelude ()
import Data.Bool
import Data.Eq
import Data.Maybe
import Data.Map
import Data.Function

import Text.Show
import Control.Monad.Reader

import qualified Position as P
import MoveTypes
import Piece
import Square

type PReader = Reader P.Position

assailants :: Color -> Square -> PReader [Square]
assailants c sq =
    [pawnAssailants, 
                  kingAssailants, 
                  queenAssailants,
                  knightAssailants,
                  bishopAssailants,
                  rookAssailants]

kingSquares :: Color -> PReader [Square]
kingSquares c = filterPieces (Piece King c)

filterPieces :: Piece -> PReader [Square]
filterPieces pc = do
    sqs <- pieceSquares
    filterM (hasPiece pc) sqs

hasPiece :: Piece -> Square -> PReader Bool
hasPiece pc sq = do
    mpc <- pieceAt sq
    return (mpc == Just pc)

--
-- Accessors
--

pieceAt :: Square -> PReader (Maybe Piece)
pieceAt sq = boardAccessor (lookup sq)

pieceSquares :: PReader [Square]
pieceSquares = boardAccessor keys

board :: PReader P.Board
board = accessor P.board

turn :: PReader Color
turn = accessor P.turn

--
-- Definitions

accessor :: (P.Position -> a) -> PReader a
boardAccessor :: (P.Board -> a) -> PReader a

accessor f = fmap f ask
boardAccessor f = accessor (f. P.board)