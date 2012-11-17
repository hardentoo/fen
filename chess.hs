module Chess where
import Control.Applicative
import Control.Monad
import Control.Monad.Trans.Reader
import Control.Monad.Trans.Cont
import Square
import Game
import Piece

color :: GameReader Color
color = asks $ whoseMove . props
color' = invert <$> color


relCPS :: (Color -> Int) -> GameReader (Cont r Int)
relCPS f = return <$> f <$> color 

relOf :: (Color -> Int) -> Square -> GameReader (Maybe Square)
relOf f sq = return runCont `ap` relCPS f `ap` return (hoffset sq)

leftOf = relOf left1
rightOf = relOf right1
above = relOf up1
below = relOf down1

--flip runCont `liftM2` (return $ hoffset sq) (relCPS f)

pieceAt s = asks $ (!! s)


-- Find all candidates able to reach s
{--
findCandidates :: Square -> GameM String [Square]
findCandidates s = do
    p <- pieceAt s
    c <- color
    case p of
        Just (Piece _ c2) -> if c /= c2
            then return $ takers s
            else fail "Can't take same-colored piece"
        Nothing -> movers s

takers s = return []
movers s = return []
--}