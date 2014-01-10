-module(udp_server).
-export([start_link/0]).

start_link() ->
  Pid = spawn_link(fun() -> loop() end),
  {ok, Pid}.

loop() ->
  lager:info("Starting udp server"),
  {ok, Socket} = gen_udp:open(8789, [list, {active,false}]),
  loop({Socket, 0}).

loop({Socket, I}) ->
  case gen_udp:recv(Socket, 0, 2000) of
    {ok, {_, _, Message}} ->
      redis_server:parse(Message),
      loop({Socket, I + 1});
    {error, timeout} ->
      lager:info("upd server received ~p messages", [I]),
      loop({Socket, I})
  end.
