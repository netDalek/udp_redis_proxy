-module(redis_server).
-behaviour(gen_server).

-export([parse/1, start_link/0]).

% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2,
         handle_info/2, terminate/2, code_change/3]).

start_link() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

parse(Message) ->
  gen_server:cast(?MODULE, {parse, Message}).

init([]) ->
  lager:info("Starting redis_server"),
  {ok, Redis} = eredis:start_link(),
  {ok, Redis}.

handle_call(_Msg, _From, St) ->
  {stop, unknown_request, St}.

handle_cast({parse, Message}, Redis) ->
  Args = parse_message(Message),
  {ok, Reply} = eredis:q(Redis, Args),
  lager:info("Redis request ~p reply ~p", [Args, Reply]),
  {noreply, Redis}.

handle_info(_Info, St) ->
  {noreply, St}.

terminate(_Reason, _St) -> ok.

code_change(_OldVsn, St, _Extra) -> {ok, St}.

with_index(List) ->
  lists:zip(List, lists:seq(1, length(List))).

parse_message(Message) ->
  [_|Tokens] = string:tokens(Message, "\r\n"),
  [ E || {E, I} <- with_index(Tokens), I rem 2 =:= 0].
