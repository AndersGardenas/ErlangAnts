%%%-------------------------------------------------------------------
%%% @author Box-Muller transformation http://www.design.caltech.edu/erik/Misc/Gaussian.html
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. Dec 2015 19:51
%%%-------------------------------------------------------------------
-module(gauess_random).


%% API
-export([get_number/0]).
% derived from example in the documentation of SRFI27
% and translated to Erlang



% slow...
%get_number() ->
%  math:sqrt( - 2 *  math:log(rand:uniform())) * math:cos( 2 * math:pi() * rand:uniform()).


get_number() ->
  X1 = 2.0 * rand:uniform() - 1.0,
  X2 = 2.0 * rand:uniform() - 1.0,
  W = X1 * X1 + X2 * X2,
  if W < 1 ->
    final_number(W,X1,X2);
    true ->
      get_number()
  end.

final_number(W,X1,X2) ->
  FinalW = math:sqrt( (-2.0 * math:log10( W ) ) / W ),
  {X1 * FinalW,  X2 * FinalW}.