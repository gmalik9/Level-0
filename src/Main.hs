module Main where

import Logic
import World
import Game
import Graphics
import Types
import Utils
import Stage

import Graphics.UI.SDL     as SDL
import Graphics.UI.SDL.TTF as TTF
import Control.Monad (forM_)
import System.Random (randomRIO)
import System.Directory (getAppUserDataDirectory, createDirectoryIfMissing)
import System.Environment (getArgs)
import System.Exit
import Data.Word (Word32)
 
main = do
    args <- getArgs
    
    -- make sure the conf directory exists...
    dataDir <- getAppUserDataDirectory "config/level_0"
    createDirectoryIfMissing True dataDir
    
    -- start your engines
    SDL.init [InitEverything]
    TTF.init

    font <- openFont (dataDir ++ "/font.ttf") 18

    setCaption "Level 0" ""
    setVideoMode windowWidth windowWidth 24 [HWSurface, DoubleBuf]
    surface <- getVideoSurface

    -- starting item X and Y
    (speed, stage'') <- case args of
        [speed, path] -> return (read speed :: Word32, fileToStage path)
        [speed]       -> return (read speed :: Word32, fileToStage (dataDir ++ "/map"))
        _             -> return (16, fileToStage (dataDir ++ "/map"))
    
    stage' <- stage''
    
    start <- randomXY (startWorld (P 16 16) (P 0 0) [] [] stage')

    -- display intro
    drawWorld surface font (startWorld (P 16 16) start [] [] stage')
    drawText  surface font "Press space to begin." 0 (-60)
    SDL.flip surface

    playGame <- doUntil waitEventBlocking $ \event -> case event of
        KeyDown (Keysym SDLK_SPACE _ _) -> A
        Quit                            -> B
        _                               -> C
    
    if not playGame
        then do
            oldScores' <- fmap lines $ readFile (dataDir ++ "/score")

            -- force the buffer to close
            length oldScores' `seq` return ()

            let oldScores = map (\x -> read x :: Int) oldScores'

            game <- gameLoop surface font (startWorld (P 16 16) start [] oldScores stage') speed
            
            SDL.quit
            
            -- write score to a file
            forM_ (map ((++ "\n") . show) (scores game)) $ \score' ->
                appendFile (dataDir ++ "/score") score'

            -- finish up
            exitWith ExitSuccess
        else do
            -- this wasn't a very meaningful existence at all
            SDL.quit
            exitWith ExitSuccess
