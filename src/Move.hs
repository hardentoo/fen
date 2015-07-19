{-# LANGUAGE TemplateHaskell #-}
module Move where
import Data.Eq
import Data.Maybe
import Text.Show
import Control.Lens

import Square
import Piece
import MoveType
import MoveDescription as Description


data Move src = 
    PawnMove { _description :: Description src, _promotion :: Maybe OfficerType } | 
    OfficerMove { _description :: Description src, _officerType :: OfficerType }

makeLenses ''Move


source :: Simple Lens (Move src) src
source = description . Description.source

destination :: Simple Lens (Move src) Square
destination = description . Description.destination

moveType :: Simple Lens (Move src) MoveType
moveType = description . Description.moveType
