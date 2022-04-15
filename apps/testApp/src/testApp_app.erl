%%%-------------------------------------------------------------------
%% @doc testApp public API
%% @end
%%%-------------------------------------------------------------------

-module(testApp_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    testApp_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
