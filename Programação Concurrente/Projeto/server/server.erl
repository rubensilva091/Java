-module(server).
-import(fileFuns, [readFile/0, writeFile/1, deleteFileParcialy/1]).
-import(miscFuns, [parseTriple/1, isUserStored/3]).
-import(lobby, [lobby_manager/2]).
-import(comunication, [speakClient/0, listenClient/1]).
-import(game, [initGame/0, game/3]).
-export([start/1, server/1, stop/1, waitConnection/1, process_login/1, loop/1]).

start(Port) -> register(?MODULE, spawn(fun() -> server(Port) end)).

%Function to stop the server
stop(Server) -> Server ! stop.

%Function that will start the server
server(Port) ->
    case  gen_tcp:listen(Port, [{active, false}, {reuseaddr, true}]) of
        {ok, Socket} ->
            register(lobby,spawn(fun() -> lobby_manager(1,[]) end)),  %TENHO DE ALTERAR ISTO PARA 0 e tenho de alterar os valores para +1
            register(game, spawn(fun() -> game([],[],[]) end)),
            register(comunicator,spawn(fun() -> speakClient() end)), 
            waitConnection(Socket);
        {error, Reason} ->
            io:format("Error Server: ~p~n", [Reason])
    end.

%Function that will wait for N connections of clients (Maximum 4)
waitConnection(Socket) ->
        case gen_tcp:accept(Socket) of 
            {ok, NewSocket} ->
                %This Spawn will wait for other client to connect it
                %Then, we can garantee that the server will always have a Thread per user
                spawn(fun() -> waitConnection(Socket) end), 
                process_login(NewSocket);
            {error, Reason} ->
                io:fwrite("Error in waitConnection: ~p~n", [Reason])
        end.

process_login(Socket) ->
    Users = readFile(),
    io:format("Users: ~p~n", [Users]),
    case gen_tcp:recv(Socket, 0) of
        {ok, Data} ->
            %Filter the listen of the client (login page)
            case parseTriple(Data) of
                ["CreateAcc", User, Pass] ->
                    case isUserStored(Users, User, Pass) of
                        %in case of user already exists and password is right
                        {ok, Level} ->
                            io:format("Wrong Button, Press Login for your Leved ~p account~n", [Level]),
                            process_login(Socket);
                        %in case of user already exists and password is not right
                        {error, 0} ->
                            io:format("User already exists!~n"),
                            process_login(Socket);
                        %in case of user does not exists
                        {error, _} ->
                            NewUser = string:join([User, Pass, "1"], " "),
                            writeFile(NewUser),
                            io:format("Account Created Successfully!~n"),
                            process_login(Socket)
                    end;
                ["LoginAcc", User, Pass] ->
                    case isUserStored(Users, User, Pass) of
                        %in case of user already exists and password is right
                        {ok, Level} ->
                            lobby ! {hi, self()},  %Send a message to the lobby
                            spawn(fun() -> listenClient(Socket) end),
                            loop(Socket);
                        %in case of user already exists and password is not right
                        {error, 0} ->
                            io:format("Wrong Password, Try again!~n"),
                            process_login(Socket);
                        %in case of user does not exists
                        {error, Reason} ->
                            io:format("~s~n", [Reason]),
                            process_login(Socket)
                    end;
                ["DeleteAcc", User, Pass] ->
                    case isUserStored(Users, User, Pass) of
                        %in case of user already exists and password is right
                        {ok, Level} ->
                            io:format("Account Level ~s deleted!~n", [Level]),
                            deleteFileParcialy(User),
                            process_login(Socket);
                        %in case of user already exists and password is not right
                        {error, 0} ->
                            io:format("Wrong Password!~n"),
                            process_login(Socket);
                        %in case of user does not exists
                        {error, Reason} ->
                            io:format("~s~n", [Reason]),
                            process_login(Socket)
                    end;
                _ ->
                    io:format("Failed to parse data.~n"),
                    process_login(Socket)
            end;
        {error, Reason} ->
            io:format("Error receiving data from client: ~p~n", [Reason])
    end.

loop(Socket) ->
    receive
        {start} ->
            %Send a message to the client that we are READY!!!
            comunicator ! {Socket,"game\n"}; 
        {id, Id} ->
            %Send the ID to the client
            comunicator ! {Socket, "id "++ integer_to_list(Id)++"\n"};
        {mobs, Str} ->
            %send player or planet or something else...
            comunicator ! {Socket,Str};%string already processed in game.erl
        {dead, Id} ->
            %Send the ID of the dead player
            comunicator ! {Socket, "dead "++ Id++"\n"};
        {_} -> 
            io:format("Command not recognized~n")
    end,
    loop(Socket).