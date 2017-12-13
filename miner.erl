-module(miner).
-export([start/0, doit2/1]).
-define(Peer, "http://localhost:8081/").
-define(CORES, 3).

start_many(N, _) when N < 1-> [];
start_many(N, Me) -> 
    Pid = spawn(fun() -> Me ! os:cmd("./amoveo_c_miner") end),
    [Pid|start_many(N-1, Me)].
kill_os_mains() -> os:cmd("killall amoveo_c_miner").
doit2(R) ->
    <<_:(8*11), R2/binary>> = list_to_binary(R),
    {First, R3} = slice(R2, hd("\"")),
    <<_:(8*2), R4/binary>> = R3,
    {Second, R5} = slice(R4, hd("\"")),
    <<_:8, R6/binary>> = R5,
    {Third, _} = slice(R6, hd("]")),
    F = base64:decode(First),
    S = base64:decode(Second),
    file:write_file("mining_input", <<F/binary, S/binary, Third/binary>>),
%we write these bytes into a file, and then call the c program, and expect the c program to read the file.
% when the c program terminates, we read the response from a different file.
    start_many(?CORES, self()),
    receive _ -> ok end,
    flush(),
    kill_os_mains(),
    {ok, <<Nonce:256>>} = file:read_file("nonce.txt"),
    BinNonce = base64:encode(<<Nonce:256>>),
    Data = << <<"[\"mining_data\",\"">>/binary, BinNonce/binary, <<"\"]">>/binary>>,
    talk_helper(Data, ?Peer, 10),
    io:fwrite("Found a block.\n"),
    timer:sleep(1000),
    start2().
start() ->
    io:fwrite("Started mining.\n"),
    start2().
start2() ->
    Data = <<"[\"mining_data\"]">>,
    R = talk_helper(Data, ?Peer, 10),
    doit2(R).
talk_helper(Data, Peer, N) ->
    if 
        N == 0 -> io:fwrite("cannot connect to server");
        true -> 
            case httpc:request(post, {Peer, [], "application/octet-stream", iolist_to_binary(Data)}, [{timeout, 3000}], []) of
                {ok, {_Status, _Headers, []}} ->
                    talk_helper(Data, Peer, N - 1);
                {ok, {_, _, R}} -> R;
                _ -> io:fwrite("\nYou need to turn on and sync your Amoveo node before you can mine. You can get it here: https://github.com/zack-bitcoin/amoveo \n"),
                     1=2
            end
    end.
slice(Bin, Char) ->
    slice(Bin, Char, 0).
slice(Bin, Char, N) ->
    NN = N*8,
    <<First:NN, Char2:8, Second/binary>> = Bin,
    if
        N > size(Bin) -> 1=2;
        (Char == Char2) ->
            {<<First:NN>>, Second};
        true ->
            slice(Bin, Char, N+1)
    end.
flush() ->
    receive
        _ ->
            flush()
    after
        0 ->
            ok
    end.
