{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import System.Environment (lookupEnv)
import Web.Scotty

main :: IO ()
main = do
  rawPort <- lookupEnv "PORT"
  let port = maybe 3033 read rawPort :: Int
  putStrLn ("haskell-scotty listening on http://127.0.0.1:" ++ show port)
  scotty port $ do
    get "/" $ do
      setHeader "content-type" "application/json"
      text "{\"service\":\"haskell-scotty\",\"framework\":\"scotty\"}"
