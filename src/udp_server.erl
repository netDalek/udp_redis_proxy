-module(udp_server).
-export([start_link/0]).

start_link() ->
  Pid = spawn_link(fun() -> loop() end),
  {ok, Pid}.

loop() ->
  lager:info("Starting udp server"),
  {ok, Socket} = gen_udp:open(8789, [list, {active,true}]),
  loop({Socket, 0}).

loop({Socket, I}) ->
  receive
    {udp, _Port, _IP, _PortNumber, Message} ->
      redis_server:parse(Message),
      loop({Socket, I + 1})
  after
    2000 ->
      lager:info("upd server received ~p messages", [I]),
      loop({Socket, I})
  end.
