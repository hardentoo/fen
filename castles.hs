module Castles(castles, CastlingMove(..), kingSquare, kingDestinationSquare,
               rookSourceSquare, rookDestinationSquare, whose,
               expendedCastlingRight, lookupFromRookSourceSquare) where
import Control.Applicative
import Control.Monad (unless)
import Control.Monad.Error (throwError)
import Data.Maybe (fromJust)

import Piece(PieceType(..), OfficerType(..), officer)
import ErrorMonad (Reason(..))
import CastlingSide (Side(..)) 
import CastlingRight (Right(Castles))
import Position 
import Threats (squareIsThreatened)
import Color (firstRank, Color(..))
import qualified Square (series, Square, Series)
import Square (square')

data CastlingMove = 
    CastlingMove { position::Position, side::Side } deriving (Show, Eq)

expendedCastlingRight mv = Castles (side mv) (whose mv)

castles p s = do
    verifyHasRights p s
    verifyKingCanMoveSafely p s
    kingAndRookShouldBeInPlace p s
    return $ CastlingMove p s

kingAndRookShouldBeInPlace p s = unless (kingInPlace p && rookInPlace p s) $
    internalError "missing piece, can't castle"

kingInPlace p = Just king == readSquare p (kingSquare c)
    where king = officer King c
          c = whoseTurn p

rookInPlace p s = Just rook == readSquare p (rookSourceSquare r)
    where r = Castles s c
          rook = officer Rook c
          c = whoseTurn p

verifyHasRights p s = unless (hasRights p s) $
    throwError InsufficientCastlingRights

hasRights p s = right `elem` castlingRights p
    where right = Castles s (whoseTurn p)

verifyKingCanMoveSafely p s = unless (kingCanMoveSafely p s) $
    throwError EnemyPiecesHinderCastling

kingCanMoveSafely p s =
    squareIsThreatened p `none` transitionSquares p s

none f = not. any f

transitionSquares :: Position -> Side -> Square.Series
transitionSquares p s = transitionSquares' $ Castles s (whoseTurn p)
transitionSquares' r@(Castles _ c) = Square.series from to
    where from = kingSquare c
          to = kingDestinationSquare r

kingSquare :: Color -> Square.Square
kingSquare c = case lookup c kingSquares of
    Just sq -> sq
    Nothing -> internalError "King not found, can't castle"
    where kingSquares = [(White, square' 'e' 1), (Black, square' 'e' 8)]

kingDestinationSquare (Castles s c) = square' (kingDestinationFile s) (firstRank c)
    where kingDestinationFile Kingside = 'g'
          kingDestinationFile Queenside = 'c'

rookSourceSquare (Castles s c) = square' (rookSourceFile s) (firstRank c)
    where rookSourceFile Kingside = 'h'
          rookSourceFile Queenside = 'a'

rookDestinationSquare :: Right -> Square.Square
rookDestinationSquare (Castles s c) = square' (rookDestinationFile s) (firstRank c)
    where rookDestinationFile Kingside = 'f'
          rookDestinationFile Queenside = 'd'

lookupFromRookSourceSquare a = lookup a table
    where table = zip squares rights
          rights = Castles <$> [Queenside, Kingside] <*> [White, Black]
          squares = rookSourceSquare <$> rights

internalError err = error $ "Internal error in castles-module: " ++ err

whose = whoseTurn. position
