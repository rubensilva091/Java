-module(lobby).
-export([lobby_manager/2, wake_Game/1]).

%Function to manage the lobby and count the number of players in the lobby
lobby_manager(NumberPlayers, Players) ->
    io:format("Lobby Manager~n"),
    case NumberPlayers of
        0 ->    
            io:format("Lobby Empty~n"),
            receive
                {hi, PID} ->
                    PID ! {id, NumberPlayers},
                    lobby_manager(NumberPlayers + 1,Players++[PID])
            end;
        1-> 
            io:format("~w Player in the Lobby~n", [NumberPlayers]),
            receive
                {hi, PID} ->
                    PID ! {id, NumberPlayers},
                    lobby_manager(NumberPlayers + 1,Players++[PID])
            end;

        4 ->
            io:format("Lobby is FULL!~n"),
            wake_Game(Players),
            game ! {start, Players};
        _ ->
            io:format("~w Players in the Lobby~n", [NumberPlayers]),
            receive
                {hi, PID} ->
                    PID ! {id, NumberPlayers},
                    lobby_manager(NumberPlayers + 1,Players++[PID])
                after 5000 ->
                    io:format("5 Seconds elapsed without anyone joining~n"),
                    wake_Game(Players),
                    game ! {start, Players}
                    %%falta adicionar o que acontece quando o jogo acaba   
            end
    end.

wake_Game([H|T]) ->
    H ! {start},
    wake_Game(T);
wake_Game([]) ->
    io:format("Enjoy the game !~n").
