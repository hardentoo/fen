module TestUtils where
import Test.HUnit
import Test.Hspec

import Control.Monad.Reader

import PositionReader
import FENDecode

hasPawnAt :: String -> PReader Spec
hasPawnAt s = pieceSatisfyingAt (\pc -> pieceType pc == Pawn) s "has pawn"

pieceSatisfyingAt :: (Piece -> Bool) -> String -> String -> PReader Spec
pieceSatisfyingAt f s txt = do
    pc <- pieceAt (square' s)
    return $ 
        describe ("square " ++ s) $ do
            it (s ++ " isn't empty ") (assertJust pc) 
            withJust' $ \p ->
                it txt (f p)

withInitialPosition :: PReader Spec -> Spec
withInitialPosition = withPosition initialFEN

withPosition :: String -> PReader Spec -> Spec
withPosition fen r =
    let label = "position " ++ fen
        assertion = decode fen `withRight` runReader r
    in label `describe` assertion


withRight :: (Show a, Show b) => Either a b -> (b -> Spec) -> Spec
withRight x f = do
    it "is valid" (assertRight x)
    withRight' x f

withRight' :: Either a b -> (b -> Spec) -> Spec
withRight' (Right a) f = f a
withRight' _ _ = doNothing

withJust' :: Just a -> (a -> Spec) -> Spec
withJust' (Just x) f = f x
withJust' _ = doNothing

assertRight x = x `shouldSatisfy` isRight
assertJust x = x `shouldSatisfy` isJust

isRight :: Either a b -> Bool
isRight (Right _) = True
isRight _ = False


doNothing = return ()
