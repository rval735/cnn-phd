----
---- CNN-PhD version 0.1, Copyright (C) 25/Jun/2018
---- Creator: rval735
---- This code comes with ABSOLUTELY NO WARRANTY; it is provided as "is".
---- This is free software under GNU General Public License as published by
---- the Free Software Foundation; either version 3 of the License, or
---- (at your option) any later version. Check the LICENSE file at the root
---- of this repository for more details.
----

-- | Extra functions to complement CAN
module CANExtras
-- (
-- )
where

import           CANTypes
import           Data.Array.Repa       (computeS, fromFunction, fromListUnboxed,
                                        ix1, ix2, traverse2)
import           Data.Array.Repa.Index ((:.) (..), Z (..))
import           Data.Bool             (bool)
import           ListExtras            (applyNTimes, binaryList, num2Bin',
                                        shiftLeft)

createZNeuron :: Int -> Int -> CANNeuron
createZNeuron rowI colI = CANNeuron (CANWElem initialValue canW0) (CANTElem initialValue canT0)
    where canW0 = createNNTMU rowI colI []
          canT0 = createNTTVU rowI (fromIntegral colI) []

createNNTMU' :: Int -> Int -> [NTT] -> NNTMU
createNNTMU' rowI colI = createNNTMU rowI colI . binaryList

createNNTMU :: Int -> Int -> [NNT] -> NNTMU
createNNTMU rowI colI [] = fromListUnboxed (ix2 rowI colI) $ replicate (rowI * colI) False
createNNTMU rowI colI xs
    | length xs /= (rowI * colI) = createNNTMU rowI colI []
    | otherwise = fromListUnboxed (ix2 rowI colI) xs

createNTTVU :: Int -> NTT -> [NTT] -> NTTVU
createNTTVU rowI colI xs
    | rowI < 0 || colI < 0 = createZNTTVU 0
    | null xs = colIVec
    | length xs /= rowI = createZNTTVU rowI
    | otherwise = fromListUnboxed (ix1 rowI) xs
    where colIVec = computeS $ fromFunction (ix1 rowI) (const colI)

createZNTTVU :: Int -> NTTVU
createZNTTVU rowI
    | rowI <= 0 = computeS $ fromFunction (ix1 0) (const 0)
    | otherwise = computeS $ fromFunction (ix1 rowI) (const 0)

createNNTVU :: Int -> [NNT] -> NNTVU
createNNTVU elems [] = fromListUnboxed (ix1 elems) $ replicate elems False
createNNTVU elems xs
    | length xs /= elems = createNNTVU elems []
    | otherwise = fromListUnboxed (ix1 elems) xs

createNNTVU' :: Int -> [NTT] -> NNTVU
createNNTVU' elems xs = createNNTVU elems $ binaryList xs

createNNTVULst :: Int -> [Int] -> [NNTVU]
createNNTVULst _ [] = []
createNNTVULst binLength xs = map elemsLst xs
    where elemsLst = fromListUnboxed (ix1 binLength) . reverse . num2Bin' binLength

construct1Complement :: Int -> Int -> NNTMU
construct1Complement startPos rows
    | startPos > rows = emptyArr
    | startPos < 0 = emptyArr
    | otherwise = computeS $ traverse2 emptyArr indexesArr const flipIndexes
    where emptyArr = fromListUnboxed (ix2 rows rows) $ replicate (rows * rows) False
          indexesLst = applyNTimes (fromIntegral startPos) shiftLeft [0 .. (rows - 1)]
          indexesArr = fromListUnboxed (ix1 rows) indexesLst
          flipIndexes f g sh@(Z :. x :. y) = let val = g (ix1 x) in bool False True (val == y)

constructUpdate :: NTT -> [CANUpdate]
constructUpdate nnElems = elems (nnElems - 1)
    where canElems = [CANWeight, CANThreshold]
          elems n = reverse $ concatMap (\x -> map (CANUpdate x) canElems) [0 .. n]
