%%%-------------------------------------------------------------------
%%% @author anders
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. Dec 2015 15:38
%%%-------------------------------------------------------------------
-module(ants).
-author("anders").

%% API
-export([new/3,update/3]).
-import( ant, [newAnt/2,update/2,looking_for_food/1]).
-import(map,[close_to_food/3]).



new(N,X,Y)->
  Ants =  [ {X,Y} || _ <- lists:duplicate(N,1)],
  AntsInfo =  [ ant:newAnt(random:uniform()*2 -1,random:uniform()*2 -1) || _ <- lists:duplicate(N,1)],
  {Ants,AntsInfo}.

update(Ant,Map,Time)->
  update(Ant,{[],[]},Map,Time).
update(Ant,{AntPos,AtomInfo},Map,Time)->
  {A,OldAntPos,I, OldAntInfo} = getNext(Ant),

  {X,Y} = A,
  {Pos,Info} = ant:update(X,Y,I,Map,Time),
  NewAntPos =  [Pos] ++ AntPos,
  NewAntInfo = [Info] ++ AtomInfo,

  if OldAntPos == [] ->
    {NewAntPos,NewAntInfo};
    true ->
      update({OldAntPos, OldAntInfo},{NewAntPos,NewAntInfo},Map,Time)
  end.



getNext(Ant)->
  {[A|AntPos],[I|AntInfo]} = Ant,
  {A,AntPos,I,AntInfo}.



