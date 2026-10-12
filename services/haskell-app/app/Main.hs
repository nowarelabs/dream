{-# LANGUAGE OverloadedStrings #-}

module Main (main) where

import qualified Data.ByteString.Lazy.Char8 as BL
import Network.HTTP.Types (status200)
import qualified Network.Wai as Wai
import qualified Network.Wai.Handler.Warp as Warp
import System.Environment (lookupEnv)

body :: BL.ByteString
body = "{\"service\":\"haskell-app\"}"

app :: Wai.Application
app _ respond = respond (Wai.responseLBS status200 [("content-type", "application/json")] body)

main :: IO ()
main = do
  rawPort <- lookupEnv "PORT"
  let port = maybe 4033 read rawPort :: Int
  putStrLn ("haskell-app listening on http://127.0.0.1:" ++ show port)
  Warp.run port app
