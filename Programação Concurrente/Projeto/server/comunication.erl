-module(comunication).
-import(miscFuns, [parseTriple/1]).
-export([speakClient/0, listenClient/1]).

speakClient() ->
    receive
        {Socket, Data} ->
            gen_tcp:send(Socket, Data),
            speakClient()
    end.


listenClient(Socket) ->
    case gen_tcp:recv(Socket, 0) of
        {ok, Data} ->
            case parseTriple(Data) of
                ["key", Command, ID] ->
                    game ! {updateCliente, Command, ID};
                _ ->
                    nothing
            end,
            listenClient(Socket);
        {error, closed} ->
            io:format("Connection closed.~n", []);
        {error, Reason} ->
            io:format("Error: ~p~n", [Reason])
    end.