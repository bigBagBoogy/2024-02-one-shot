// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console, Vm} from "../lib/forge-std/src/Test.sol";
import {RapBattle} from "../src/RapBattle.sol";
import {OneShot} from "../src/OneShot.sol";
import {Streets} from "../src/Streets.sol";
import {Credibility} from "../src/CredToken.sol";
import {IOneShot} from "../src/interfaces/IOneShot.sol";
import {Handler} from "test/Handler.t.sol";

contract Invariant is Test {
    RapBattle rapBattle;
    OneShot oneShot;
    Streets streets;
    Credibility cred;
    IOneShot.RapperStats stats;
    address user;
    address challenger;
    Handler handler;

    function setUp() public {
        oneShot = new OneShot();
        cred = new Credibility();
        streets = new Streets(address(oneShot), address(cred));
        rapBattle = new RapBattle(address(oneShot), address(cred));
        user = makeAddr("Alice");
        challenger = makeAddr("Slim Shady");

        oneShot.setStreetsContract(address(streets));
        cred.setStreetsContract(address(streets));
        // when deploying handler, need to pass constructor params
        handler = new Handler(rapBattle, oneShot, streets, user, challenger);

        bytes4[] memory selectors = new bytes4[](1);
        selectors[0] = handler.goOnStageOrBattle.selector;

        targetSelector(FuzzSelector({addr: address(handler), selectors: selectors}));
    }

    function invariant_test_BetsMustMatch() public {
        if (user[_credBet] == challenger[_credBet]) {
            vm.expectRevert();
        }
        rapBattle.goOnStageOrBattle(1, 1);
    }
}
