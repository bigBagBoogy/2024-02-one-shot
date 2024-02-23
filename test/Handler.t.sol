// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console, Vm} from "../lib/forge-std/src/Test.sol";
import {RapBattle} from "../src/RapBattle.sol";
import {OneShot} from "../src/OneShot.sol";
import {Streets} from "../src/Streets.sol";
import {Credibility} from "../src/CredToken.sol";
import {IOneShot} from "../src/interfaces/IOneShot.sol";

contract Handler is Test {
    RapBattle rapBattle;
    OneShot oneShot;
    Streets streets;
    Credibility cred;
    // IOneShot.RapperStats stats;
    address user;
    address challenger;

    constructor(
        RapBattle _rapBattle,
        OneShot _oneShot,
        Streets _streets,
        // Credibility _cred,
        address _user,
        address _challenger
    ) {
        rapBattle = _rapBattle;
        oneShot = _oneShot;
        streets = _streets;
        // cred = _cred;
        user = _user;
        challenger = _challenger;
    }

    // synopsis of test: mint a rapper
    // mint another rapper
    // they may stake to be different RapperSkill (first equal though)
    // they initiate a battle / with fuzzed _credBet, bound between 0 and 10
    // We'll expectRevert(if(bets don't match)) If !revert =>
    // so that if there is no revert, but the bets don't match the test should fail
    // if 2 rappers initiate, we'll check if their bettings match

    function goOnStageOrBattle(uint256 credBet, uint256 credBet2) public {
        vm.startPrank(user);
        oneShot.mintRapper(); // rapper 0
        oneShot.approve(address(rapBattle), 0); // approve contract for tokenId 0
        credBet = bound(credBet, 0, 10);
        rapBattle.goOnStageOrBattle(0, credBet); // ID, _credBet amount
        vm.stopPrank();

        vm.startPrank(challenger);
        oneShot.mintRapper();
        oneShot.approve(address(rapBattle), 1);
        credBet2 = bound(credBet2, 0, 10);
        rapBattle.goOnStageOrBattle(1, credBet2); // ID, _credBet amount
    }
}

/**
 * @dev Gives permission to `to` to transfer `tokenId` token to another account.
 * The approval is cleared when the token is transferred.     *
 * Only a single account can be approved at a time, so approving the zero address clears previous approvals.     *
 * Requirements:     *
 * - The caller must own the token or be an approved operator.
 * - `tokenId` must exist.     *
 * Emits an {Approval} event.
 */
