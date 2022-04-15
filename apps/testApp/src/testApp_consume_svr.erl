-module(testApp_consume_svr).
-behaviour(gen_server).
-include_lib("brod/include/brod.hrl").
%% API
-export([start_link/0]).
%% callback api
-export([init/2, handle_message/4]).
-export([init/1]).

init(_GroupId, _Arg) -> {ok, []}.

%% brod_group_subscriber behaviour callback
handle_message(_Topic, Partition, Message, State) ->
    #kafka_message{
        offset = Offset,
        key = Key,
        value = Value
    } = Message,
    io:fwrite("Kafka message ~p ~n", [Message]),
    {ok, ack, State}.

%% gen_server callbacks

-define(SERVER, ?MODULE).

-record(kafka_consumer_svr_state, {}).

%%%===================================================================
%%% API
%%%===================================================================
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================
init([]) ->
    Topic = <<"test-topic">>,
    %% commit offsets to kafka every 5 seconds
    GroupConfig = [
        {offset_commit_policy, commit_to_kafka_v2},
        {offset_commit_interval_seconds, 5}
    ],
    GroupId = <<"test_group_id">>,
    ConsumerConfig = [{begin_offset, earliest}],
    brod:start_link_group_subscriber(
        client1,
        GroupId,
        [Topic],
        GroupConfig,
        ConsumerConfig,
        _CallbackModule = ?MODULE,
        _CallbackInitArg = []
    ),
    {ok, #kafka_consumer_svr_state{}}.
