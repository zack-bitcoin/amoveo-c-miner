-module(miner)
.
-export([start/0, unpack_mining_data/1, speed_test/0]).
%-define(Peer, "http://localhost:8081/").%for a full node on same computer.
%-define(Peer, "http://localhost:8085/").%for a mining pool on the same computer.
-define(Peer, "http://159.89.106.253:8085/").%for a mining pool on the server.
-define(CORES, 2).
-define(Pubkey, <<"BMjV7rAAssU+DGd8w+6XsyDSdgoichddlSipZT3U+jehHSD68UwPdF9TO3HQ0g4hCh2rgUQyqPnP7vP0i/l8Ijw=">>). %If you are using a full node on the same computer, then it does not use this pubkey. Instead it uses the pubkey stored in the full node. 
-define(period, 10).%how long to wait in seconds before checking if new mining data is available.
-define(pool_sleep_period, 1000).%How long to wait in miliseconds if we cannot connect to the mining pool.
-define(miner_sleep, 0). %This is how you reduce the load on CPU. It sleeps this long in miliseconds between mining cycles.


start_many(N, _) when N < 1-> [];
start_many(N, Me) -> 
    Pid = spawn(fun() -> Me ! os:cmd("./amoveo_c_miner " ++ integer_to_list(N)) end),
    [Pid|start_many(N-1, Me)].
kill_os_mains() -> os:cmd("pkill amoveo_c_miner").
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
    R = talk_helper(Data, ?Peer, 1000),
    if
	is_list(R) ->
	    start_c_miners(R);
	is_atom(R) -> 
	    timer:sleep(1000),
	    start()
    end.
read_nonce(0) -> 0;
read_nonce(N) ->
    io:fwrite("read nonce n is "),
    io:fwrite(integer_to_list(N)),
    io:fwrite("\n"),
    case file:read_file("nonce.txt") of
	{ok, <<Nonce:256>>} -> Nonce;
	{ok, <<>>} -> 
	    io:fwrite("nonce failed "),
	    io:fwrite(integer_to_list(N)),
	    io:fwrite("\n"),
	    timer:sleep(100),
	    read_nonce(N-1)
    end.

	   
speed_test() -> 
    Third = <<0>>,
    F = <<0:256>>,
    RS = F,
    file:write_file("mining_input", <<F/binary, RS/binary, Third/binary>>).
    
start_c_miners(R) ->
    {F, _, Third} = unpack_mining_data(R), %S is the nonce
    RS = crypto:strong_rand_bytes(32),
    ok = file:write_file("nonce.txt", <<"">>),
    file:write_file("mining_input", <<F/binary, RS/binary, Third/binary>>),%32 byte hash, 32 byte nonce, integer
%we write these bytes into a file, and then call the c program, and expect the c program to read the file.
% when the c program terminates, we read the response from a different file.
    flush(),
    start_many(?CORES, self()),
    receive _ -> 
	    kill_os_mains(),
            io:fwrite("Found a block. 1\n"),
	    Nonce = read_nonce(2),
	    case Nonce of 
		0 -> io:fwrite("nonce 0 error\n");
		_ ->
		    BinNonce = base64:encode(<<Nonce:256>>),
		    Data = << <<"[\"work\",\"">>/binary, BinNonce/binary, <<"\",\"">>/binary, ?Pubkey/binary, <<"\"]">>/binary>>,
		    talk_helper(Data, ?Peer, 5),
		    io:fwrite("Found a block. 2\n"),
		    timer:sleep(200)
	    end
    after (?period * 1000) ->
	    kill_os_mains(),
            io:fwrite("did not find a block in that period \n"),
            ok
    end,
    timer:sleep(?miner_sleep),
    start2().
talk_helper2(Data, Peer) ->
    httpc:request(post, {Peer, [], "application/octet-stream", iolist_to_binary(Data)}, [{timeout, 3000}], []).
talk_helper(_Data, _Peer, 0) -> throw("talk helper failed");
talk_helper(Data, Peer, N) ->
    case talk_helper2(Data, Peer) of
        {ok, {_Status, _Headers, []}} ->
            io:fwrite("server gave confusing response\n"),
            timer:sleep(?pool_sleep_period),
            talk_helper(Data, Peer, N-1);
        {ok, {_, _, R}} -> R;
        %{error, _} ->
        E -> 
            io:fwrite("\nIf you are running a solo-mining node, then this error may have happened because you need to turn on and sync your Amoveo node before you can mine. You can get it here: https://github.com/zack-bitcoin/amoveo \n If this error happens while connected to the public mining node, then it can probably be safely ignored."),
             timer:sleep(?pool_sleep_period),
             talk_helper(Data, Peer, N-1)
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
        _ -> flush()
    after
        0 -> ok
    end.
