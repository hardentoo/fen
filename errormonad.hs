module ErrorMonad (
    Reason(..),
    ErrorMonad
    ) where

import Control.Monad.Error 

data Reason = LastRankPromote | NoPieceToMove | NoPromotion | ColorsMismatch

instance Error Reason where
noMsg = error "noMsg called"
strMsg s = "strMsg called"

type ErrorMonad = Either Reason