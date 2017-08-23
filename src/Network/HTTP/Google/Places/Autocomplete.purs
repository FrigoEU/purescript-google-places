module Network.HTTP.Google.Places.Autocomplete where

import Prelude 

import Data.Foreign (F, Foreign)
import Data.Foreign.Class (class Decode, decode)
import Data.Foreign.Generic (defaultOptions, genericDecode)
import Data.Foreign.Generic.EnumEncoding (defaultGenericEnumOptions, genericDecodeEnum)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Maybe (Maybe(..), maybe)
import Data.MediaType (MediaType)
import Data.MediaType.Common (applicationJSON)
import Data.Newtype (class Newtype)
import Data.Tuple (Tuple(..), fst, snd)
import Network.HTTP.Affjax (Affjax, get)
import Network.HTTP.Affjax.Response (class Respondable, ResponseType(..))

type QueryOptions = { input :: String
                    , key :: String
                    , location :: Maybe {latitude :: Number, longitude :: Number}
                    , offset :: Maybe Int
                    , radius :: Maybe Number
                    , language :: Maybe String
                    , types :: Maybe PredictionType
                    , strictbounds :: Maybe Boolean
                    }
data QueryStatus = OK
                 | ZERO_RESULTS
                 | OVER_QUERY_LIMIT
                 | REQUEST_DENIED
                 | INVALID_REQUEST
data PredictionType = Geocode
                    | Address
                    | Establishment
instance showPredictionType :: Show PredictionType where
  show pt = case pt of
                 Geocode -> "geocode"
                 Address -> "address"
                 Establishment -> "establishment"
newtype QueryResponse = QueryResponse { status :: QueryStatus
                                      , predictions :: Array Prediction
                                      }
newtype Prediction = Prediction { description :: String
                                , id :: String
                                -- , matched_substrings :: Array {length :: Int, offset :: Int}
                                , place_id :: String
                                , reference :: String
                                -- , terms :: Array {offset :: Int, value :: String}
                                }
derive instance genericQueryStatus :: Generic QueryStatus _
derive instance genericQueryResponse :: Generic QueryResponse _
derive instance newtypeQueryResponse :: Newtype QueryResponse _
derive instance genericPrediction :: Generic Prediction _
derive instance newtypePrediction :: Newtype Prediction _
instance decodeQueryStatus :: Decode QueryStatus where
  decode = genericDecodeEnum defaultGenericEnumOptions
instance decodeQueryResponse :: Decode QueryResponse where
  decode = genericDecode (defaultOptions {unwrapSingleConstructors = true})
instance decodePrediction :: Decode Prediction where
  decode = genericDecode (defaultOptions {unwrapSingleConstructors = true})
instance showPrediction :: Show Prediction where show = genericShow
instance showQueryStatus :: Show QueryStatus where show = genericShow
instance showQueryResponse :: Show QueryResponse where show = genericShow

instance respondableQueryResponse :: Respondable QueryResponse where
  fromResponse :: Foreign -> F QueryResponse
  fromResponse = decode
  responseType :: Tuple (Maybe MediaType) (ResponseType QueryResponse)
  responseType = Tuple (Just applicationJSON) JSONResponse

query :: forall e. QueryOptions -> Affjax e QueryResponse
query = get <<< makeUrl

makeUrl :: QueryOptions -> String
makeUrl opts =
  "https://maps.googleapis.com/maps/api/place/autocomplete/json?"
  <> "input=" <> opts.input
  <> "&key=" <> opts.key
  <> (maybe "" (\loc -> "&location=" <> show loc.latitude <> "," <> show loc.longitude) opts.location)
  <> (maybe "" (\offset -> "&offset=" <> show offset) opts.offset)
  <> (maybe "" (\radius -> "&offset=" <> show radius) opts.radius)
  <> (maybe "" (\language -> "&language=" <> language) opts.language)
  <> (maybe "" (\sb -> "&strictbounds=" <> show sb) opts.strictbounds)
  <> (maybe "" (\types -> "&types=" <> show types) opts.types)
