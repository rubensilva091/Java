-module(miscFuns).
-export([parseTriple/1, isUserStored/3]).

%Function to parse triple
parseTriple(Str) ->
    Data = re:replace(Str,"\\n|\\r|", "",[global,{return,list}]),
    ParsedData = string:split(Data, " ", all),
    ParsedData.

%Function to check if user exists
isUserStored([Head|Tail], User, Pass) ->
    [Username, Password, Level] = string:split(Head, " ", all),
    case Username == User andalso Password == Pass of
        true ->
            {ok, Level};
        false ->
            case Username == User andalso Password /= Pass of
                true ->
                    {error, 0};
                false ->
                    isUserStored(Tail, User, Pass)
            end
    end;

isUserStored([], _, _) ->
    {error, "User not found"}.