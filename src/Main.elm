module Main exposing (..)

import Html exposing (Html, div, h1, img, text)
import Html.Attributes exposing (src)
import Window exposing (Size, resizes)


---- MODEL ----


type alias Model =
    { width : Int
    , height : Int
    }


init : ( Model, Cmd Msg )
init =
    ( { width = 0, height = 0 }, Cmd.none )



---- UPDATE ----


type Msg
    = ResizeWindow Size


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ResizeWindow { width, height } ->
            ( { model | width = width, height = height }, Cmd.none )



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Window.resizes (\{ height, width } -> ResizeWindow (Size width height))
        ]



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ text "width: "
        , text <| toString model.width
        , text ", height: "
        , text <| toString model.height
        ]



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
