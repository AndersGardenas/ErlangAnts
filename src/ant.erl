%%%-------------------------------------------------------------------
%%% @author anders
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. Dec 2015 19:26
%%%-------------------------------------------------------------------
-module(ant).
-author("anders").

%% API
-export([newAnt/3,update/5,getXDir/1,getYDir/1,setXDir/2,setYDir/2,looking_for_food/1]).

-record(ant,{xDir,yDir,time,fromHive}).

newAnt(XDir,YDir,Time) ->
  #ant{xDir = XDir,yDir = YDir,time = 0, fromHive = true}.

update(X,Y,Ant,Map,Time)->
  %NewTime = Ant#ant:time - TimeDif,
  Looking_for_food = ant:looking_for_food(Ant),
  if Looking_for_food == ture ->
    Close = map:close_to_food(Map,X,Y),
    if Close == false ->
      XDir = Ant#ant.xDir + normal_random:get_number(),
      YDir = Ant#ant.yDir + normal_random:get_number();
      true ->
        {NewX,NewY} = Close,
        XDir = NewX-X,
        YDir = NewY-Y
    end;
    true->
      XDir = Ant#ant.xDir + normal_random:get_number(),
      YDir = Ant#ant.yDir + normal_random:get_number()
  end,

  Ratio = 1.0/math:sqrt(XDir*XDir+YDir*YDir),
  Ant#ant{xDir = XDir *Ratio, yDir = YDir*Ratio
    ,time =+ Time }.


getXDir(Ant)->
  Ant#ant.xDir.

getYDir(Ant)->
  Ant#ant.yDir.

setXDir(Ant,Dir)->
  Ant#ant{xDir = Dir}.

setYDir(Ant,Dir)->
  Ant#ant{yDir = Dir}.

looking_for_food(Ant)->
  Ant#ant.fromHive.