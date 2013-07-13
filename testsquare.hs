import Test.HUnit
import Square

import Data.Maybe (fromJust)

tests = TestLabel "Square Tests" testList

testList = TestList [
            TestLabel "square creation" squareTests,
            TestLabel "horizontal series" $ TestCase testHorizontalSeries,
            TestLabel "file letters" $ TestCase testFileLetters,
            TestLabel "rank numbers" $ TestCase testRankNumbers,
            TestCase testAbove, TestCase testBelow
            ]

squareTests = TestList [ TestCase testSquare, TestCase testSquareFail ]

testSquare =
    let s = square 'a' 3
        s' = fromJust $ s
     in do
        assertBool "is square" (Nothing /= s)
        assertEqual "right file" 'a' $ file s'
        assertEqual "right file" 3 $ rank s'

testSquareFail =
    let s = square 'z' 4
     in do
        assertEqual "No square" Nothing $ s

testFileLetters = assertLength 8 fileLetters
testRankNumbers = assertLength 8 fileLetters

testHorizontalSeries = do
    let start = square' 'a' 3
    let end = square' 'e' 3
    let s = series start end
    assertString $ show s
    assertLength 5 s
    assertEqual "first square" start $ head s
    assertEqual "last square" end $ last s

testAbove = let s = square' 'e' 4
                s' = square' 'e' 5
             in assertEqual "above" (Just s') (above s)

testBelow = let s = square' 'e' 4
                s' = square' 'e' 3
             in assertEqual "below" (Just s') (below s)

assertLength l a = assertEqual s l $ length a
    where s = "length " ++ show l