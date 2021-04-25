module ImageSearch where

import Prelude

import Data.Maybe (Maybe(..))
import Effect.Aff.Class (class MonadAff)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Web.Event.Event (preventDefault) as Event
import Web.Event.Internal.Types (Event)


type Input = {}

type State = { text :: String }

type Slot id = forall query. H.Slot query Output id

data Action = SetText String | EmitText Event

data Output = TextSet String

imageSearch :: forall q m. MonadAff m => H.Component q Input Output m
imageSearch =
  H.mkComponent
    { initialState
    , render
    , eval: H.mkEval H.defaultEval { handleAction = handleAction }
    }
  where
    initialState :: Input -> State
    initialState input = { text: "" }

render :: forall m. State -> H.ComponentHTML Action () m
render state =
  HH.div
    [ HP.classes [ HH.ClassName "max-w-sm rounded overflow-hidden my-10 mx-auto"] ]
    [ HH.form
        [ HP.classes [ HH.ClassName "w-full max-w-sm" ]
        , HE.onSubmit EmitText
        ]
        [ HH.div
            [ HP.classes [ HH.ClassName "flex items-center border-b border-b-2 border-teal-500 py-2" ] ]
            [ HH.input
                [ HP.classes [ HH.ClassName "appearance-none bg-transparent border-none w-full text-gray-700 mr-3 py-1 px-2 leading-tight focus:outline-none" ]
                , HP.type_ HP.InputText
                , HP.placeholder "Search Image Term..."
                , HP.value state.text
                , HE.onValueInput SetText
                ]
            , HH.button
                [ HP.classes [ HH.ClassName "flex-shrink-0 bg-teal-500 hover:bg-teal-700 border-teal-500 hover:border-teal-700 text-sm border-4 text-white py-1 px-2 rounded " ]
                , HP.type_ HP.ButtonSubmit
                ]
                [ HH.text "Search" ]
            ]
        ]
    ]

handleAction :: forall m. MonadAff m => Action -> H.HalogenM State Action () Output m Unit
handleAction = case _ of
  SetText text -> do
    H.modify_ _ { text = text }

  EmitText event -> do
    H.liftEffect $ Event.preventDefault event
    text <- H.gets _.text
    H.raise (TextSet text)
