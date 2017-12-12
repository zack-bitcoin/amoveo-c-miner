-module(miner).
-export([doit/0, start/0, doit2/0]).

start() -> 
    application:start(inets).
    
doit() ->
    Peer = "http://localhost:8081/",
    Data = <<"[\"mining_data\"]">>,
    R = talk_helper(Data, Peer, 10),
    <<_:(8*11), R2/binary>> = list_to_binary(R),
    {First, R3} = slice(R2, hd("\"")),
    <<_:(8*2), R4/binary>> = R3,
    {Second, _} = slice(R4, hd("\"")),
    F = base64:decode(First),
    S = base64:decode(Second),
    file:write_file("mining_input", <<F/binary, S/binary>>),
    [base64:decode(First), base64:decode(Second)].
%we should probably write these bytes into a file, and then call the c program, and expect the c program to read the file.
doit2() ->
    Me = self(),
    _Pid = spawn(fun() ->
                        Response = os:cmd("ls"),
                        Me ! Response
                end),
    receive
        X -> X
    end.
talk_helper(Data, Peer, N) ->
    if 
        N == 0 -> io:fwrite("cannot connect to server");
        true -> 
            case httpc:request(post, {Peer, [], "application/octet-stream", iolist_to_binary(Data)}, [{timeout, 3000}], []) of
                {ok, {_Status, _Headers, []}} ->
                    talk_helper(Data, Peer, N - 1);
                {ok, {_, _, R}} -> R;
                X -> io:fwrite("talk helper unexpected"),
                     io:fwrite(X),
                     error
            end
    end.
slice(Bin, Char) ->
    slice(Bin, Char, 0).
slice(Bin, Char, N) ->
    NN = N*8,
    <<First:NN, Char2:8, Second/binary>> = Bin,
    if
        (Char == Char2) ->
            {<<First:NN>>, Second};
        true ->
            slice(Bin, Char, N+1)
    end.
