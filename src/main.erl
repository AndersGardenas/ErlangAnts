%%%-------------------------------------------------------------------
%%% @author anders
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. Dec 2015 18:03
%%%-------------------------------------------------------------------
-module(main).
-author("anders").

%% API
-export([main/0,run/0]).
-import( map, [new/8,update/2]).
-import(ants,[new/ 3,update/3]).

-define(FPS,1/60).
-define(WaintTime,10000).

main() ->
  %% Node = node("clientNode"),
  io:format("Started erlang prog \n"),
  receive doNothing ->
    ok
  end.




run()->
  io:format("Run has started \n"),
  receive {init,MasterPid,NrAnts,WorldMax,Start,FoodX,FoodY,NrActors} ->
    io:format("Recived pid ~p \n", [MasterPid]),
    io:format("Recived NrAnts ~p \n", [NrAnts]),
    io:format("Recived WorldMax ~p  \n", [WorldMax]),
    io:format("Recived Start ~p  \n", [Start]),
    io:format("Recived NrActors ~p  \n", [NrActors])
  after ?WaintTime ->
    MasterPid = self(),
    NrAnts = 10.0,
    WorldMax = 10.0,
    Start = 10.0,
    NrActors = 10,
    FoodX = 0,
    FoodY = 0,
    throw("out of time ")
  end,


  HivePhoromon = hive,
  FoodPhoromon = food,
  ets:new(HivePhoromon,[set,named_table,public]),
  ets:new(FoodPhoromon,[set,named_table,public]),

  %Init world
  StartX = Start,
  StartY = Start,
  Map = map:new(0,WorldMax,0,WorldMax,[{FoodX,FoodY}],[{StartX,StartY}],HivePhoromon,FoodPhoromon),

  Self = self(),
  NrAntPerActor = round(max(NrAnts /NrActors ,1)),

  io:format("Number of ants per actors is ~p  \n", [NrAntPerActor]),
  Pids = [spawn_link(fun () -> ants(Self, NrAntPerActor,StartX,StartY,Map,MasterPid) end) || _ <- lists:duplicate(NrActors,1)],

  run(Pids,Map, erlang:timestamp(),MasterPid,60).

%Main loop
run(Pids,Map,OldTime,MasterPid,PrintFPS) ->
  NewTime =erlang:timestamp(),
  if PrintFPS > 0 ->
    io:format("Fps is ~p \n", [1000000/timer:now_diff(NewTime,OldTime)]),
    NewPrintFPS = 60;
    true ->
      NewPrintFPS = PrintFPS -1
  end,

  FirstTimeDif = timer:now_diff(NewTime,OldTime)/1000000,
  if(FirstTimeDif < ?FPS)->
    timer:sleep(round(?FPS*1000 -FirstTimeDif*1000));
    true ->
      ok
  end,
  FinalTime = erlang:timestamp(),
  TimeDif = timer:now_diff(FinalTime,OldTime)/1000000,


  %update all ants
  Refs = [send_message(Pid,TimeDif) || Pid <- Pids],
  lists:foreach(
    fun (Ref) ->
      receive Ref ->
        ok
      end
    end
    ,Refs),


  map:update(Map,TimeDif),
  run(Pids,Map,FinalTime,MasterPid,NewPrintFPS).

%Send a message to a Ant
send_message(Pid,TimeDif)->
  Ref =  make_ref(),
  Pid ! {Ref,TimeDif},
  Ref.


%Ants
ants(Pid,N,X,Y,Map,JavaPid)->
  Ants = ants:new(N,X,Y),

  ants(Pid,Ants,Map,JavaPid).
ants(Pid,Ants,Map,JavaPid)->

  receive {Ref,Time} ->
    NewAnts = ants:update(Ants,Map,Time),
    {NewAntsPos,_} = NewAnts,
    JavaPid ! NewAntsPos,
    Pid ! Ref
  after ?WaintTime ->
    NewAnts = null,
    throw("out of time ")
  end,
  ants(Pid,NewAnts,Map,JavaPid).




