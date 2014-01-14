-module(udp_redis_proxy_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(normal, _StartArgs) ->
    lager:start(),
    udp_redis_proxy_sup:start_link().

stop(_State) ->
    ok.
