module ImageGrid where

import Prelude

import Affjax (Error(..), printError)
import Affjax as AX
import Affjax.ResponseFormat as AXRF
import Control.Bind (bindFlipped)
import Control.Monad.Except.Trans (ExceptT(..), runExceptT)
import Data.Bifunctor (lmap)
import Data.Either (either)
import Data.Maybe (Maybe(..))
import Data.Newtype (wrap)
import Data.String.Common (split)
import Data.Symbol (SProxy(..))
import Effect.Aff.Class (class MonadAff)
import Effect.Class.Console (log)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Properties as HP
import ImageSearch (Output(..), imageSearch)
import ImageSearch (Output) as ImageSearch
import Simple.JSON (readJSON)


type Slots = ( imageSearch :: forall query. H.Slot query ImageSearch.Output Int )

_imageSearch = SProxy :: SProxy "imageSearch"

type Tag = String

type Hit =
  { id :: Int
  , webformatURL :: String
  , user :: String
  , views :: Int
  , downloads :: Int
  , likes :: Int
  , tags :: String
  }

type Image =
  { total :: Int
  , totalHits :: Int
  , hits :: Array Hit
  }

type State =
  { loading :: Boolean
  , images :: Array Hit
  , term :: String
  }

apiKey :: String
apiKey = "16825054-ba06b8349177c260e7635ff28"

type Input = Unit

data Action = Initialize | FetchImages | HandleSearch ImageSearch.Output

component :: forall q i o m. MonadAff m => H.Component HH.HTML q i o m
component =
  H.mkComponent
    { initialState
    , render
    , eval: H.mkEval H.defaultEval { handleAction = handleAction, initialize = Just Initialize }
    }

initialState :: forall i. i -> State
initialState _ = { loading: false, images: [], term: "" }

render :: forall m. MonadAff m => State -> H.ComponentHTML Action Slots m
render state =
  HH.div
    [ HP.classes [ HH.ClassName "container mx-auto" ] ]
    [ HH.slot _imageSearch 0 imageSearch {} (Just <<< HandleSearch)
    , HH.div
        [ HP.classes [ HH.ClassName "grid grid-cols-3 gap4" ] ]
        (renderImages state)
    ]

renderImages :: forall m. State -> Array (H.ComponentHTML Action Slots m)
renderImages state = if state.loading
  then
    [ HH.h1
      [ HP.classes [ HH.ClassName "text-6xl text-center mx-auto mt-32" ] ]
      [ HH.text "Loading..." ] ]
  else
    map
    (\img -> HH.div
      [ HP.classes [ HH.ClassName "max-w-sm rounded overflow-hidden shadow-lg" ] ]
      [ HH.img
          [ HP.classes [ HH.ClassName "w-full" ], HP.src img.webformatURL ]
      , HH.div
          [ HP.classes [ HH.ClassName "px-6 py-4" ] ]
          [ HH.div
              [ HP.classes [ HH.ClassName "font-bold text-purple-500 text-xl mb-2" ] ]
              [ HH.text $ "Photo by " <> img.user
              , HH.ul []
                  [ HH.li [] [ HH.strong [] [ HH.text $ "Downloads: " <> show img.downloads ] ]
                  , HH.li [] [ HH.strong [] [ HH.text $ "Views: " <> show img.views  ] ]
                  , HH.li [] [ HH.strong [] [ HH.text $ "Likes: " <> show img.likes  ] ]
                  ]
              ]
          , HH.div
              [ HP.classes [ HH.ClassName "px-6 py-4" ] ]
              (map renderTag (split (wrap ",") img.tags))
          ]
      ]) state.images

renderTag :: forall m. Tag -> H.ComponentHTML Action Slots m
renderTag tag =
  HH.span
    [ HP.classes [ HH.ClassName "inline-block bg-gray-200 rounded-full px-3 py-1 text-sm font-semibold text-gray-700 mr-2" ] ]
    [ HH.text $ "#" <> tag ]


handleAction :: forall o m. MonadAff m => Action -> H.HalogenM State Action Slots o m Unit
handleAction = case _ of
  Initialize -> do
    handleAction FetchImages

  FetchImages -> bindFlipped (either (printError >>> log) pure) $ runExceptT do
    H.modify_ _ { loading = true }
    term <- H.gets _.term
    response <- ExceptT $ H.liftAff $ AX.get AXRF.string ("https://pixabay.com/api/?key=" <> apiKey <> "&q=" <> term <> "&image_type=photo&pretty=true")
    (decoded :: Image) <- ExceptT $ pure $ (lmap (show >>> RequestContentError) $ readJSON response.body)
    H.modify_ _ { loading = false, images = decoded.hits }

  HandleSearch output ->
    case output of
      TextSet text -> do
        H.modify_ _ { term = text }
        handleAction FetchImages
