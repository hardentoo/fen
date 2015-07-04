module Candidates where
import Prelude ()
import Control.Applicative
import Control.Monad
import Data.Function
import Data.Monoid
import Data.Maybe
import Data.List
import Data.Eq
import Control.Monad.Reader
import Control.Monad.Plus

import PositionReader
import qualified Position
import Piece
import Square
import Movement
import SquareListUtils
import Directions
import PieceSquares
import MoveType
import MoveDescription


candidates :: MoveDescription d => d -> PReader [Square]
candidates desc = do
    let dest = destination desc
        mt = moveType desc
        finder = candidateFinder mt
    c <- turn
    sqs <- finder c dest
    return $ filter (possibleSource desc) sqs

type CandidateFinder = Color -> Square -> PReader [Square]

candidateFinder Captures = allAssailants
candidateFinder Moves = allReachers


allAssailants :: CandidateFinder

allAssailants c sq = do
    as <- mapM (flip assailants sq) (allPiecesColored c)
    return (mconcat as)



allReachers :: CandidateFinder

allReachers c sq = do
    oas <- mapM (flip assailants sq) (allOfficersColored c)
    mp <- pawnReaching c sq
    return (mconcat oas ++ mfromMaybe mp)



pawnReaching :: Color -> Square -> PReader (Maybe Square)
pawnReaching c sq = firstPiece pawn (pawnMoveSquares c sq)
    where pawn = Piece Pawn c



assailants :: Piece -> Square -> PReader [Square]

assailants pawn@(Piece Pawn c) sq = filterM (hasPiece pawn) (pawnAttackSquares c sq)

assailants piece@(Piece (Officer officer) c) sq = do
    first <- mapM (firstPiece piece) (officerSquares officer sq)
    return (catMaybes first)



allPiecesColored :: Color -> [Piece]
allPiecesColored c = Piece <$> [Pawn ..] <*> [c]

allOfficersColored :: Color -> [Piece]
allOfficersColored c = allPiecesColored c \\ [Piece Pawn c]