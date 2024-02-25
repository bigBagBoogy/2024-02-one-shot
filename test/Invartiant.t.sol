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
        handler = new Handler(rapBattle, oneShot, streets, cred, user, challenger);

        bytes4[] memory selectors = new bytes4[](4);
        selectors[0] = handler.goOnStageOrBattle.selector;
        selectors[1] = handler.stake.selector;
        selectors[2] = handler.unStake.selector;
        selectors[3] = handler.mintRapper.selector;

        targetSelector(FuzzSelector({addr: address(handler), selectors: selectors}));
    }

    function invariant_test_BetsMustMatch() public {
        // console.log(handler.someGhostVar());
        if (rapBattle.defender() == address(0)) {
            // if there is no defender
            return;
        } else {
            uint256 _credBet = 3;
            vm.startPrank(challenger);
            oneShot.mintRapper(); // = challenger = slim shady = tokenId
            uint256 challengerRapperId = oneShot.getNextTokenId();
            oneShot.approve(address(rapBattle), challengerRapperId); // takes:  spender, (erc721)rapperId
            cred.approve(address(rapBattle), 10);
            console.log("defenderBet = ", handler.defenderBet());
            if (handler.defenderBet() == _credBet) {
                vm.expectRevert();
                rapBattle.goOnStageOrBattle(challengerRapperId, _credBet); // ID, _credBet amount
            }
        }
    }
}
