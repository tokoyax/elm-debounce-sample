module Main exposing (..)

--import Html.Attributes exposing (src)

import Html exposing (Html, div, h1, img, li, text, ul)
import Process
import Task exposing (Task)
import Time exposing (Time, millisecond)
import Window exposing (Size)


---- MODEL ----


type alias Model =
    { state : Maybe State
    , stateHistory : List (Maybe State)
    , isLocked : Bool
    }


type alias State =
    { width : Int
    , height : Int
    , updateCount : Int
    }


type alias Flags =
    { width : Int
    , height : Int
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        model =
            { state = Just (initState flags)
            , stateHistory = [ Just (initState flags) ]
            , isLocked = False
            }
    in
    ( model
    , Cmd.none
    )


initState : Flags -> State
initState f =
    { width = f.width
    , height = f.height
    , updateCount = 0
    }


delay : Model -> Cmd Msg
delay model =
    Process.sleep (2000 * millisecond)
        |> Task.perform (\_ -> TimeOut)



---- UPDATE ----


type Msg
    = ResizeWindow Size
    | TimeOut
    | Lock


andThen : Msg -> ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
andThen msg ( model, cmd ) =
    let
        ( newmodel, newcmd ) =
            update msg model
    in
    newmodel ! [ cmd, newcmd ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ResizeWindow { width, height } ->
            let
                state =
                    case model.state of
                        Just state ->
                            Just
                                { state
                                    | width = width
                                    , height = height
                                    , updateCount = state.updateCount + 1
                                }

                        Nothing ->
                            Debug.crash "model.state is Nothing in update"
            in
            ( { model
                | stateHistory = state :: model.stateHistory
              }
            , Cmd.none
            )
                |> andThen Lock

        TimeOut ->
            let
                newState =
                    case List.head model.stateHistory of
                        Just state ->
                            state

                        Nothing ->
                            Debug.crash "ここがNothingなんてありえないYO"
            in
            ( { model
                | state = newState
                , stateHistory = [ newState ]
                , isLocked = False
              }
            , Cmd.none
            )

        Lock ->
            let
                cmd =
                    if model.isLocked == True then
                        Cmd.none
                    else
                        delay model
            in
            ( { model | isLocked = True }
            , cmd
            )



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Window.resizes (\{ height, width } -> ResizeWindow (Size width height))
        ]



---- VIEW ----


view : Model -> Html Msg
view model =
    let
        state =
            case model.state of
                Just s ->
                    s

                Nothing ->
                    Debug.crash "model.state is Nothing in view"
    in
    div []
        [ text "width: "
        , text <| toString state.width
        , text ", height: "
        , text <| toString state.height
        , text ", updateCount: "
        , text <| toString state.updateCount
        , text ", isLocked: "
        , text <| toString model.isLocked
        ]



---- PROGRAM ----


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
