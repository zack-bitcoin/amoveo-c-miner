-module(miner).
-export([start/0, unpack_mining_data/1]).
-define(Peer, "http://localhost:8085/").
-define(CORES, 3).
-define(mode, pool).
-define(Pubkey, <<"BHjaeLteq9drDIhp8d0R6JmUqkivIW1M0Yoh5rsGnw4wePMKowcNGHqfttAF52jMYhsZicFr7eIOWN/Sr0XI+OI=">>).
-define(period, 6).%how long to wait in seconds before checking if new mining data is available.
%This should probably be around 1/20th of the blocktime.


start_many(N, _) when N < 1-> [];
start_many(N, Me) -> 
    Pid = spawn(fun() -> Me ! os:cmd("./amoveo_c_miner " ++ integer_to_list(N)) end),
    [Pid|start_many(N-1, Me)].
kill_os_mains() -> os:cmd("killall amoveo_c_miner").
unpack_mining_data(R) ->
    <<_:(8*11), R2/binary>> = list_to_binary(R),
    {First, R3} = slice(R2, hd("\"")),
    <<_:(8*2), R4/binary>> = R3,
    {Second, R5} = slice(R4, hd("\"")),
    <<_:8, R6/binary>> = R5,
    {Third, _} = slice(R6, hd("]")),
    F = base64:decode(First),
    S = base64:decode(Second),
    {F, S, Third}.
start() ->
    io:fwrite("Started mining.\n"),
    start2().
start2() ->
    kill_os_mains(),
    flush(),
    Data = <<"[\"mining_data\"]">>,
    R = talk_helper(Data, ?Peer, 10),
    start_c_miners(R).
start_c_miners(R) ->
    {F, S, Third} = unpack_mining_data(R),
    file:write_file("mining_input", <<F/binary, S/binary, Third/binary>>),
%we write these bytes into a file, and then call the c program, and expect the c program to read the file.
% when the c program terminates, we read the response from a different file.
    start_many(?CORES, self()),
    
    receive _ -> 
            io:fwrite("Found a block. 1\n"),
            {ok, <<Nonce:256>>} = file:read_file("nonce.txt"),
            BinNonce = base64:encode(<<Nonce:256>>),
            Data = << <<"[\"work\",\"">>/binary, BinNonce/binary, <<"\",\"">>/binary, ?Pubkey/binary, <<"\"]">>/binary>>,
                                                %talk_helper2(Data, ?Peer),
            talk_helper(Data, ?Peer, 40),%spend 8 seconds checking 5 times per second if we can start mining  again.
            io:fwrite("Found a block. 2\n"),
            timer:sleep(200)
    after (?period * 1000) ->
            io:fwrite("did not find a block in that period \n"),
            ok
    end,
    kill_os_mains(),
    flush(),
    start2().
talk_helper2(Data, Peer) ->
    httpc:request(post, {Peer, [], "application/octet-stream", iolist_to_binary(Data)}, [{timeout, 3000}], []).
talk_helper(Data, Peer, N) ->
    if 
        N == 0 -> 
            io:fwrite("cannot connect to server"),
            1=2;
        true -> 
            case talk_helper2(Data, Peer) of
                {ok, {_Status, _Headers, []}} ->
                    timer:sleep(200),
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
