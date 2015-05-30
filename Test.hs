module Test where
import Test.HUnit
import Test.Hspec

import Control.Monad.Reader

import PositionReader
import FENDecode

-- TODO This module is the work in progess module for testing out the program


--withInitialPosition :: String -> Spec
--withInitialPosition = withPosition initialFEN

{-
 - Intended example usage:
stuff = withInitialPosition $ do
    hasOfficerAt Knight "e4"
    hasPawnAt "d2"
    hasPawnAt "e2"
    afterMoves "e4 e5 Nc3" $ do
        hasPawnAt "e4"
        hasNoPieceAt "e2"

withSquare :: String -> Reader Square Spec -> Spec
withSquare s =
    describe ("square " ++ s) $
        case s of
            Nothing -> -}

parseMoves :: String -> Either a b
parseMoves fen = undefined



afterMoves :: String -> PReader Spec -> Spec
afterMoves m r = 
    describe ("moves " ++ m) $ do
        let mvs = parseMoves e
        it "parse correctly" $ assertRight mvs
        mvs `withRight` \mvs' -> do
            let p = afterMany mvs'
            it "produces a legal position" $ assertRight p
            p `withRight` \p' -> do
                describe "in resulting position" $
                    runReader r p'
        
--
-- Testing utils
-- TODO move

withPosition :: String -> PReader Spec -> Spec
withPosition fen r =
    let p = decode fen
        text = "position " ++ fen
    in describe text $ do
        it "is valid" $ assertRight p
        withRight p $ runReader r

assertRight (Left err) = assertFailure $ show err
assertRight _ = assertSuccess
assertSuccess = return ()

withRight :: Monad m => Either a b -> (b -> m ()) -> m ()
withRight (Right a) f = f a
withRight _ _ = return ()