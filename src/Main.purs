module Main where

import Prelude

import Control.Monad.Aff (runAff)
import Control.Monad.Aff.Console (log)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE)
import Control.Monad.Eff.Console (log) as E
import Data.Maybe (Maybe(..))
import Data.Newtype (unwrap)
import Network.HTTP.Affjax (AJAX)
import Network.HTTP.Google.Places.Autocomplete (makeUrl, query)

main :: forall t39. Eff ( console :: CONSOLE , ajax :: AJAX | t39) Unit
main = void $ runAff (show >>> E.log) (\_ -> E.log "done!") $ do
  let options = { input: "Schoonstr"
                , key: ""
                , location: Nothing
                , offset: Nothing
                , radius: Nothing
                , language: Nothing
                , types: Nothing
                , strictbounds: Nothing
                }
  log (makeUrl options)
  query options >>=
    (_.response >>> unwrap >>> _.predictions >>> map (unwrap >>> _.description) >>> show >>> log)
