-module(testApp_client_svr).
-behaviour(gen_server).

%% API
-export([start_link/0]).
-export([init/1]).
-record(state, {}).
-define(SERVER, ?MODULE).

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

init(_Args) ->
    {ok, _} = application:ensure_all_started(brod),
    KafkaBootstrapEndpoints = [{"localhost", 9092}],
    Topic = <<"test-topic">>,
    Partition = 0,
    ok = brod:start_client(KafkaBootstrapEndpoints, client1),
    {ok, #state{}}.
