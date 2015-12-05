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
-export([newAnt/3,update/1,getXDir/1,getYDir/1,setXDir/2,setYDir/2]).

-record(ant,{xDir,yDir,time,maxTime}).

newAnt(XDir,YDir,Time) ->
  #ant{xDir = XDir,yDir = YDir,time = Time,maxTime = Time}.

update(Ant)->
  %NewTime = Ant#ant:time - TimeDif,

  XDir = Ant#ant.xDir + normal_random:get_number(),
  YDir = Ant#ant.yDir + normal_random:get_number(),
  Ratio = 1.0/math:sqrt(abs(XDir+YDir)),
  Ant#ant{xDir = XDir *Ratio, yDir = YDir*Ratio}.


getXDir(Ant)->
  Ant#ant.xDir.

getYDir(Ant)->
  Ant#ant.yDir.

setXDir(Ant,Dir)->
  Ant#ant{xDir = Dir}.

setYDir(Ant,Dir)->
  Ant#ant{yDir = Dir}.