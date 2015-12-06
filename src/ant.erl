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
-export([newAnt/2,update/5,getXDir/1,getYDir/1,setXDir/2,setYDir/2,
  looking_for_food/1]).
-import(gauess_random,[get_number/0]).
-import(map,[close_to_food/3,close_to_hive/3,home_dir/3,food_dir/3,
addHivePheromon/4,addFoodPheromon/4]).
-record(ant,{xDir,yDir,time,fromHive,pheromonTimer}).

newAnt(XDir,YDir) ->
  #ant{xDir = XDir,yDir = YDir,time = 0, fromHive = true,pheromonTimer = 0}.

update(X,Y,Ant,Map,Time)->
  %NewTime = Ant#ant:time - TimeDif,

  Looking_for_food = ant:looking_for_food(Ant),
  OldTime = Ant#ant.time,

  if Looking_for_food == true ->
    FoundFood = map:close_to_food(Map,X,Y),
    %Found food?
    if FoundFood == false ->
      NewTime = OldTime + Time,
      FromHive = true,
      Dir =  map:food_dir(Map,X,Y),

      %found food phoromon?
      if Dir == false ->
        {XDir,YDir} = randomDir(Ant);
        true ->
          {FoodXDir,FoodYDir} = Dir,
          XDir = FoodXDir-X,
          YDir = FoodYDir-Y
      end;
    %Found the food source
      true ->
        io:format("has food \n"),
        {XDir,YDir} = randomDir(Ant),
        NewTime = 0,
        FromHive = false
    end;

    true->

      FoundFood = map:close_to_hive(Map,X,Y),
      if FoundFood == false ->
        NewTime = OldTime+ Time,
        FromHive = false,
        Dir =  map:home_dir(Map,X,Y),

        if Dir == false ->
          {XDir,YDir} = randomDir(Ant);
          true ->
            {HomeXDir,HomeYDir} = Dir,
            XDir = HomeXDir-X,
            YDir = HomeYDir-Y
        end;

        true ->
          io:format("has hive  \n"),
          {XDir,YDir} = randomDir(Ant),
          NewTime = 0,
          FromHive = true
      end

  end,
  NewPhermonTimer = Time + Ant#ant.pheromonTimer,


  FinalPhermonTimer = updatePhermon(FromHive, NewPhermonTimer, Map, X, Y, NewTime),

  Ratio = 1.0/math:sqrt(XDir*XDir+YDir*YDir),

  Ant#ant{xDir = XDir *Ratio, yDir = YDir*Ratio,
    time = NewTime,fromHive = FromHive, pheromonTimer = FinalPhermonTimer}.


updatePhermon(FromHive, NewPhermonTimer, Map, X, Y, NewTime) ->
  if FromHive == true ->
    if NewPhermonTimer > 1 ->
      FinalPhermonTimer = 0,
      map:addHivePheromon(Map, X, Y, NewTime);
      true ->
        FinalPhermonTimer = NewPhermonTimer
    end;
    true ->
      if NewPhermonTimer > 1 ->
        FinalPhermonTimer = 0,
        map:addFoodPheromon(Map, X, Y, NewTime);
        true ->
          FinalPhermonTimer = NewPhermonTimer
      end
  end,
  FinalPhermonTimer.


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


randomDir(Ant)->
  {Ant#ant.xDir + gauess_random:get_number()/10,
    Ant#ant.yDir + gauess_random:get_number()/10}.