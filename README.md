Kafka
=====

![Kafka Structure](D:\Internship\Kafka\01-kafka-cluster-hero.png)

#### Basic Building blocks

* Zookeeper

* Client

* Producer

* Consumer

##### Zookeeper

ZooKeeper is primarily used to track the status of nodes in the Kafka cluster and maintain a list of Kafka topics and messages. It exists for management purposes.



##### Client

It is a gen_server which has the primary responsibility of establish tcp sockets to kafka brokers and maintain those connections. Once a client is started, it can be used in anywhere in the application for handling data with producers and consumers.



```erlang
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
    ok = brod:start_client(KafkaBootstrapEndpoints, client1),
    {ok, #state{}}.

```



##### Producer

Producers used to publish messages to  a specified Topic in kafka cluster.

```erlang
-module(testApp_publish).
-behaviour(application).
-export([publish/1]).

publish(Msg) ->
    Topic = <<"test-topic">>,
    Partition = 0,
    ok = brod:start_producer(client1, Topic, _ProducerConfig = []),
    {ok, FirstOffset} = brod:produce_sync_offset(
        client1, Topic, Partition, <<"key1">>, <<Msg>>
    ).

```



##### Consumer

Consumer is a gen_server that continously listen to a specified or automatically assigned partition in a specified Topic. Assigning of the partitions to consumers is done by the zookeeper. Primarily consumers exists as groups in kafka. A consumer is responsible for one or more partitions in a specified Topic. Also the maximum number of consumers in a given group cannot be more than the number of partitions in the topic that it consumes.



```erlang
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

```
