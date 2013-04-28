module Move ( Move, move, Move.position,) where

import Prelude hiding (elem)
import Data.Maybe (maybe, fromJust)
import Control.Monad (when)
import Control.Monad.Error ( throwError)

import Square ( Square, rank)
import Piece ( PieceType(..), OfficerType,)
import Color ( Color(..))
import MoveType ( MoveType(..))
import Position ( Position, readSquare, Promotion, lastRank)
import qualified ProjectedRange ( inferMoveType)
import ErrorMonad ( ErrorMonad, 
                    Reason(NoPromotion, LastRankPromote, NotInRange),)
import MovingPiece ( MovingPiece, position, square, color, 
                     pieceType, movingPiece,)

data Move = Move { movingPiece :: MovingPiece, moveType :: MoveType,
                   destination :: Square,  promotion :: Maybe Promotion }

move :: MovingPiece -> Square -> Maybe Promotion -> ErrorMonad Move
move mp d pr = do
    mt <- inferMoveType mp d
    let mv = Move mp mt d pr
    verifyPromotion mv
    return mv

inferMoveType mp d = maybe (throwError NotInRange)
    return (ProjectedRange.inferMoveType mp d)

verifyPromotion mv = case Move.pieceType mv of
    Pawn -> verifyPawnPromotion mv
    _ -> verifyOfficerPromotion mv

verifyOfficerPromotion mv = case promotion mv of
    Nothing -> return ()
    Just _ -> throwError NoPromotion

verifyPawnPromotion mv = case promotion mv of
    Nothing -> when (requiresPromotion mv) (throwError LastRankPromote)
    Just _ -> when (not. requiresPromotion $ mv) (throwError NoPromotion)

requiresPromotion :: Move -> Bool
requiresPromotion mv = Move.pieceType mv == Pawn && lastRankMove mv

lastRankMove :: Move -> Bool
lastRankMove mv = rank (destination mv) == Position.lastRank p
    where p = MovingPiece.position. Move.movingPiece $ mv

position = MovingPiece.position. Move.movingPiece
pieceType = MovingPiece.pieceType. Move.movingPiece
