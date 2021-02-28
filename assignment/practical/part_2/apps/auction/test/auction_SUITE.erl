-module(auction_SUITE).

-include_lib("common_test/include/ct.hrl").
-include_lib("eunit/include/eunit.hrl").

-export([all/0, 
         groups/0,
         init_per_suite/1,
         end_per_suite/1,
         init_per_group/2,
         end_per_group/2,
         init_per_testcase/2, 
         end_per_testcase/2]).

-export([test_start_link/1,
         test_get_starting_bid/1,
         test_save_winning_bidder/1,
         test_init/1,
         test_auction_item/1,
         test_auction_ended/1,
         test_check_for_invalid_bid/1,
         test_check_leading_bid/1,
         test_get_next_itemid/1]).

all() ->
  [{group, auction_data_dep},
   {group, statem_dep}].

groups() -> 
  [{auction_data_dep, [], [test_start_link,
                           test_get_starting_bid,
                           test_save_winning_bidder]},
   {statem_dep, [], [test_init,
                     test_auction_item,
                     test_auction_ended,
                     test_check_for_invalid_bid,
                     test_check_leading_bid,
                     test_get_next_itemid]}].

% suite setup & tear down
init_per_suite(Config) ->
  Priv = ?config(priv_dir, Config),
  io:format("priv_directory ~s~n", [Priv]),
  application:load(mnesia),
  application:set_env(mnesia, dir, Priv),
  application:load(auction_data),
  auction_data:install([node()]),
  application:start(mnesia),
  application:start(auction_data),
  Config.

end_per_suite(_Config) ->
  application:stop(mnesia),
  ok.

% group setup & tear down
init_per_group(auction_data_dep, Config) ->
  {ok, AuctionId} = auction_data:create_auction(),
  StartingBid1 = 0,
  StartingBid2 = 1,
  AuctionItems = 
    [{"book", "fiction", StartingBid2}, {"hat", "blue cap", StartingBid1}],
  {ok, [{ItemId1, "hat"}, {ItemId2, "book"}]} = 
    auction_data:add_items(AuctionId, AuctionItems),
  [{starting_bids, [StartingBid1, StartingBid2]} |
    [{auction, AuctionId} | 
      [{itemids, [ItemId1, ItemId2]} | 
        Config]]];
init_per_group(statem_dep, Config) ->
  Config.

end_per_group(auction_data_dep, Config) ->
  AuctionId = ?config(auction, Config),
  ok = auction_data:remove_auction(AuctionId);
end_per_group(statem_dep, Config) ->
  ok.

% testcase setup
init_per_testcase(_, Config) ->
  Config.

% testcase tear down
end_per_testcase(_, Config) ->
  Config.

% auction_data_dep tests
test_start_link(Config) ->
  ok.

test_get_starting_bid(Config) ->
  AuctionId = ?config(auction, Config),
  [ItemId1, ItemId2] = ?config(itemids, Config),
  [StartingBid1, StartingBid2] = ?config(starting_bids, Config),
  UndefinedStartingBid = undefined,
  StartingBid1 = 
    auction:get_starting_bid(AuctionId, ItemId1, UndefinedStartingBid),
  StartingBid2 = 
    auction:get_starting_bid(AuctionId, ItemId2, UndefinedStartingBid),
  AlreadyHaveStartingBid = 3,
  AlreadyHaveStartingBid = 
    auction:get_starting_bid(AuctionId, ItemId1, AlreadyHaveStartingBid).

test_save_winning_bidder(Config) ->
  ok.

% statem_dep tests
test_auction_item(Config) ->
  ok.

test_init(Config) ->
  ok.

test_auction_ended(Config) ->
  ok.

test_check_for_invalid_bid(Config) ->
  ok.

test_check_leading_bid(Config) ->
  ok.

test_get_next_itemid(Config) ->
  ok.