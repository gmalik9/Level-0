-- Copyright 2012 Mike Ledger
-- License: GNU GPL v3. See COPYING.
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
import Control.Monad (when, forM_)
import System.Directory (getAppUserDataDirectory, createDirectoryIfMissing)
import System.Environment (getArgs)

main :: IO ()
main = do
    args <- getArgs

    -- make sure the conf directory exists...
    dataDir <- getAppUserDataDirectory "config/level_0"
    createDirectoryIfMissing True dataDir

    (speed', stage'') <- case args of
        ["none", speed'']   -> return (read speed'', return [])
        [path, speed'']     -> return (read speed'', fileToStage path)
        [path]              -> return (16, fileToStage path)
        []                  -> return (16, return [])
        _                   -> error "usage: level_0 [stage file [speed]|stage file]. If you want to set a custom speed, you must also set the map file. For no map use 'none'"

    stage' <- stage''
    
    -- start your engines
    SDL.init [InitEverything]
    TTF.init

    font <- openFont (dataDir ++ "/font.ttf") 18

    setCaption "Level 0" ""
    setVideoMode windowWidth windowHeight 24 [HWSurface, DoubleBuf]
    surface <- getVideoSurface

    start <- randomXY (startWorld (P 16 16) (P 0 0) [] [] stage' 0)

    -- display intro
    drawWorld surface font (startWorld (P 16 16) start [] [] stage' 0)
    drawText  surface font "Press space to begin." 0 (-60)
    SDL.flip surface

    -- catch whether or not the user wants to quit at the start menu
    playGame <- while3 waitEventBlocking $ \event -> case event of
        KeyDown (Keysym SDLK_SPACE _ _) -> B
        Quit                            -> A
        _                               -> C

    when playGame $ do
        oldScores' <- fmap lines $ readFile (dataDir ++ "/score")

        -- force the buffer to close
        length oldScores' `seq` return ()

        let oldScores = map (\x -> read x :: Int) oldScores'

        game <- gameLoop surface font (startWorld (P 16 16) start [] oldScores stage' speed')

        SDL.quit

        -- write score to a file
        forM_ (map ((++ "\n") . show) (scores game)) $ \score' ->
            appendFile (dataDir ++ "/score") score'

    SDL.quit
