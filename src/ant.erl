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
-export([newAnt/2,update/5,getXDir/1,getYDir/1,
  looking_for_food/1]).
-import(gauess_random,[get_number/0]).
-import(map,[close_to_food/3,close_to_hive/3,home_dir/3,food_dir/3,
addHivePheromon/4,addFoodPheromon/4]).
-record(ant,{xDir,yDir,time,fromHive,pheromonTimer,directionTimer}).

-define(ANTSPEED,10).
-define(PHOROMONTIMER, 0.2/?ANTSPEED).
-define(IgnoringPheromonChanse,0.3).
-define(SAMEDIRECTIONTIME,0.1).
newAnt(XDir,YDir) ->
  #ant{xDir = XDir,yDir = YDir,time = 0, fromHive = true,pheromonTimer = 0,directionTimer = 0}.

%A bit messy updates the ant
update(X,Y,Ant,Map,Time)->
  if Ant#ant.directionTimer > ?SAMEDIRECTIONTIME ->

    {XDir, YDir, TimeSinceSource, FromHive} = findNewDirection(Ant, Map, X, Y, Time),

    FinalPheromonTimer = updatePhermon(FromHive, Time + Ant#ant.pheromonTimer, Map, X, Y, TimeSinceSource),

    Ratio = 1.0/math:sqrt(XDir*XDir+YDir*YDir),
    {NewX,NewY,FinalXDir,FinalYDir} = update_pos(X, Y, XDir *Ratio, YDir*Ratio,Time,  Map),
    FinalAnt = Ant#ant{xDir = FinalXDir, yDir = FinalYDir,
      time = TimeSinceSource,fromHive = FromHive, pheromonTimer = FinalPheromonTimer, directionTimer = 0},
    {{NewX,NewY},FinalAnt};
    true ->
      OldTime = Ant#ant.time,
      FinalPheromonTimer = updatePhermon(ant:looking_for_food(Ant), Time + Ant#ant.pheromonTimer, Map, X, Y, OldTime),
      {NewX,NewY,FinalXDir,FinalYDir} =update_pos(X, Y, Ant#ant.xDir, Ant#ant.yDir,Time,  Map),
      FinalAnt = Ant#ant{xDir = FinalXDir, yDir = FinalYDir,time = OldTime + Time, pheromonTimer = FinalPheromonTimer, directionTimer = Ant#ant.directionTimer + Time},
      {{NewX,NewY},FinalAnt}
  end.



findNewDirection(Ant, Map, X, Y, Time) ->
  IgnoringPheromon = random:uniform(),
  Looking_for_food = ant:looking_for_food(Ant),
  OldTime = Ant#ant.time,
  if Looking_for_food == true ->
    FoundFood = map:close_to_food(Map, X, Y),
    if FoundFood == false ->
      TimeSinceSource = OldTime + Time,
      FromHive = true,
      Dir = map:food_dir(Map, X, Y),
      {XDir, YDir} = uppdate_phoromon_direction(Dir, Ant, IgnoringPheromon, X, Y);

      true ->
        {XDir, YDir} = backwards(Ant),
        TimeSinceSource = 0,
        FromHive = false
    end;
    true ->

      FoundFood = map:close_to_hive(Map, X, Y),
      if FoundFood == false ->
        TimeSinceSource = OldTime + Time,
        FromHive = false,
        Dir = map:home_dir(Map, X, Y),
        {XDir, YDir} = uppdate_phoromon_direction(Dir, Ant, IgnoringPheromon, X, Y);

        true ->
          {XDir, YDir} = backwards(Ant),
          TimeSinceSource = 0,
          FromHive = true
      end
  end,
  {XDir, YDir, TimeSinceSource, FromHive}.





uppdate_phoromon_direction(Dir, Ant, IgnoringPheromon, X, Y) ->
  if (Dir == false) ->
    {XDir, YDir} = gauss_random_dir(Ant);
    true ->
      if IgnoringPheromon < ?IgnoringPheromonChanse ->
        {XDir, YDir} = random_dir(Ant);
        true ->
          {FoodXDir, FoodYDir} = Dir,
          XDir = FoodXDir - X,
          YDir = FoodYDir - Y
      end
  end,
  {XDir, YDir}.


updatePhermon(FromHive, PheromonTimer, Map, X, Y, TimeSinceSource) ->
  if FromHive == true ->
    if PheromonTimer > ?PHOROMONTIMER->
      FinalPheromonTimer = 0,
      map:addHivePheromon(Map, X, Y, TimeSinceSource);
      true ->
        FinalPheromonTimer = PheromonTimer
    end;
    true ->
      if PheromonTimer > ?PHOROMONTIMER ->
        FinalPheromonTimer = 0,
        map:addFoodPheromon(Map, X, Y, TimeSinceSource);
        true ->
          FinalPheromonTimer = PheromonTimer
      end
  end,
  FinalPheromonTimer.


update_pos(X, Y, XDir, YDir,Time,  Map) ->
  NewX = X + XDir * Time * ?ANTSPEED,
  NewY = Y + YDir * Time * ?ANTSPEED,
  XMim = map:get_xmin(Map),
  XMax = map:get_xmax(Map),
  YMin = map:get_ymin(Map),
  YMax = map:get_ymax(Map),
  if NewX >= XMax ->
    AnsX = XMax,
    FinalXdir = -XDir;
    NewX < XMim ->
      AnsX = XMim,
      FinalXdir = -XDir;
    true ->
      AnsX = NewX,
      FinalXdir = XDir
  end,
  if NewY >= YMax ->
    AnsY = YMax,
    FinalYdir = -YDir;
    NewY < YMin ->
      AnsY = YMin,
      FinalYdir = -YDir;
    true ->
      AnsY = NewY,
      FinalYdir = YDir
  end,
  {AnsX, AnsY, FinalXdir, FinalYdir}.

getXDir(Ant)->
  Ant#ant.xDir.

getYDir(Ant)->
  Ant#ant.yDir.


looking_for_food(Ant)->
  Ant#ant.fromHive.


gauss_random_dir(Ant)->
  {A,B} = gauess_random:get_number(),
  {Ant#ant.xDir + A/5,
    Ant#ant.yDir + B/5}.

random_dir(Ant)->
  {A,B} = gauess_random:get_number(),
  {Ant#ant.xDir + A/5,
    Ant#ant.yDir + B/5}.
 % {rand:uniform(),
  %  rand:uniform()}.

backwards(Ant) ->
  {-Ant#ant.xDir,
    -Ant#ant.yDir}.



