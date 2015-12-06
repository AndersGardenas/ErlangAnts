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
get_number() ->
  math:sqrt( - 2 *  math:log(rand:uniform())) * math:cos( 2 * math:pi() * rand:uniform()).