-- module Main where

module Lib
-- (
--     nnFunction,
--     readElems,
-- )
where

import qualified Data.ByteString       as BS
import qualified Data.ByteString.Char8 as C8
import           Data.Maybe
import           Data.Time.Clock
import           NNClass
import           System.Environment
import           System.Exit

nnFunction :: IO ()
nnFunction = do
    startTime <- getCurrentTime
    elems <- getArgs
    -- if length elems < 3 then
    --     exitFailure
    -- else


    let inputNodes = 784
    let outputNodes = 10
    let (nnBase, epochs) = readElems elems inputNodes outputNodes
    nn <- createNN nnBase

    trainingDF <- readCVS "../MNIST-Data/MNIST-Train-100.csv"
    testDF <- readCVS "../MNIST-Data/MNIST-Test-10.csv"

    -- updatedNN = map (\(x,y) -> train y (desiredOutput x) nn) trainingDataFile
    let updatedNN = doTraining epochs nn trainingDF


    endTime <- getCurrentTime
    print nn


readElems :: [String] -> Int -> Int -> (NNBase, Int)
readElems [] iN oN = (NNBase iN 1 oN 0.01, 0)
readElems [x, y, z] iN oN = (NNBase iN xx oN yy, zz)
    where xx = read x:: Int
          yy = read y :: Float
          zz = read z :: Int
readElems _ iN oN =  (NNBase iN 1 oN 0.01, 0)

readCVS :: String -> IO [(Int, [Float])]
readCVS path = do
    cvsData <- BS.readFile  "../MNIST-Data/MNIST-Test-10.csv"
    let enlined = map (map fst . mapMaybe C8.readInt . C8.split ',') . C8.lines $ cvsData
    let (elems, rep) = unzip $ map (splitAt 1) enlined
    let simplified = map head elems
    let floated = map (map normalizer) rep
    return $ zip simplified floated
    -- let floated = map (map (normalizer . fst)) tuples
    -- return floated
    -- return $
    -- map (read :: Float) enlined

normalizer :: Int -> Float
normalizer x = 0.01 + fromIntegral x / 255 * 0.99

desiredOutput :: Int -> [Float]
desiredOutput val = [if x == val then 0.99 else 0.01 | x <- [0 .. 9]]

doTraining :: Int -> NeuralNetwork -> [(Int, [Float])] -> NeuralNetwork
doTraining 0 nn _ = nn
doTraining x nn trainData = doTraining (x - 1) iterNN trainData
    where iterNN = foldr (\(x,y) -> train y (desiredOutput x)) nn trainData

-- queryNN :: NeuralNetwork -> [(Int, [Float])] -> [Bool]
-- queryNN nn testData = results
--     where (expected, test) = unzip testData
--           queried = map (map (query nn)) test
--           results = [False]


-- # We expect at least 4 elements in the program arguments
-- # which would count for hidden nodes, learning rate, and epochs.
-- if len(args) < 4:
--     print "This program needs 3 inputs in the following order:"
--     print "Hidden nodes (integer)"
--     print "Learning rate (float)"
--     print "Number of Epochs (integer)"
--     sys.exit()
--
-- # Assign the hidden nodes in the inner NN layer
-- hiddenNodes = int(args[1])
--
-- # Check that the value passed is a valid integer
-- if isinstance(hiddenNodes, int) == False:
--     print "This program needs input 1 for hidden nodes to be integer"
--     sys.exit()
--
-- # Determine how big/small steps are made after an epoch
-- learningRate = float(args[2])
-- # Check that the value passed is a valid float
-- if isinstance(learningRate, float) == False:
--     print "This program needs input 2 for learning rate to be float"
--     sys.exit()
--
-- # Number of times the training data set is iterated to train the NN
-- epochs = int(args[3])
-- # Check that the value passed is a valid integer
-- if isinstance(epochs, int) == False:
--     print "This program needs inputs 3 for epochs to be integer"
--     sys.exit()
--
-- # Number of inputs, considering a 784 size for the MNIST dataset
-- inputNodes = 784
-- # Number output nodes, which is 10 for numbers 0 to 9
-- outputNodes = 10
-- # Create instance of NN with parameters from the command line
-- n = NeuralNetwork(inputNodes, hiddenNodes, outputNodes, learningRate)
--
-- # Load MNIST dataset in CSV format into a list
-- trainingDataFile = open("../MNIST-Data/MNIST-Train.csv", 'r')
-- trainingDataList = trainingDataFile.readlines()
-- trainingDataFile.close()
--
-- # Train loop for the NN
-- for e in range(epochs):
--     # Examine records in the data set
--     for record in trainingDataList:
--         # Split the record by the ',' considering is a CVS file
--         allValues = record.split(',')
--         # Scale and shift data
--         inputs = (numpy.asfarray(allValues[1:]) / 255.0 * 0.99) + 0.01
--         # Create the target output values (all 0.01, except the desired label which is 0.99)
--         targets = numpy.zeros(outputNodes) + 0.01
--         # allValues[0] is the target label for this record, derived from the
--         # original CSV file structure.
--         targets[int(allValues[0])] = 0.99
--         # Perform the training phase for that record
--         n.train(inputs, targets)
--         pass
--     pass
--
-- # Load MNIST test data from CSV file into a list
-- testDataFile = open("../MNIST-Data/MNIST-Train-100.csv", 'r')
-- testDataList = testDataFile.readlines()
-- testDataFile.close()
--
-- # The "scorecard" keeps track of the NN performance, with init empty values
-- scorecard = []
--
-- # Run the NN performance against the test portion of the data set
-- for record in testDataList:
--     # Split the record by the ',' considering is a CVS file
--     allValues = record.split(',')
--     # allValues[0] is the target label for this record, derived from the
--     # original CSV file structure.
--     correctLabel = int(allValues[0])
--     # Scale and shift data
--     inputs = (numpy.asfarray(allValues[1:]) / 255.0 * 0.99) + 0.01
--     # Ask the NN which value the input is the record
--     outputs = n.query(inputs)
--     # Obtain the index of the highest value, which matches the expected
--     # label the NN is predicting
--     label = numpy.argmax(outputs)
--     # In case the predicted label matches, a +1 score will be appended
--     if (label == correctLabel):
--         # Case that the NN's answer matches "correctLabel"
--         scorecard.append(1)
--     else:
--         # Case NN's answer did not match, then add 0 to scorecard
--         scorecard.append(0)
--         pass
--     pass
--
-- # Calculate the NN performance, comparing the right vs wrong predictions
-- scorecardArr = numpy.asarray(scorecard)
-- error = scorecardArr.sum() / float(scorecardArr.size)
--
-- endTime = datetime.now()
-- diff = endTime - startTime
-- print "HNodes,", "LRate,", "Epochs,", "Error,", "Diff,", "STime,", "ETime"
-- print hiddenNodes, ",", learningRate, ",", epochs, ",", error, ",", diff, ",", startTime, ",", endTime
