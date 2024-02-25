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

    uint256 public someGhostVar = 55;
    uint256 public defenderBet;
    uint256 public rapperId;
    // Mapping to track minted tokens
    mapping(uint256 => bool) public isMinted;

    constructor(
        RapBattle _rapBattle,
        OneShot _oneShot,
        Streets _streets,
        Credibility _cred,
        address _user,
        address _challenger
    ) {
        rapBattle = _rapBattle;
        oneShot = _oneShot;
        streets = _streets;
        cred = _cred;
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

    function mintRapper() public {
        // Check if tokenId 0 has already been minted
        if (isMinted[0]) {
            return; // Already minted
        }
        vm.startPrank(user);
        oneShot.mintRapper();
        vm.stopPrank();
    }
    // defender go to battle

    function goOnStageOrBattle(uint256 _credBet) public {
        if (oneShot.ownerOf(0) != user) {
            // if not minted yet
            return;
        }
        uint256 balanceOfUser = cred.balanceOf(user);
        defenderBet = bound(_credBet, 0, balanceOfUser);
        vm.startPrank(user); // Alice: [0xBf0b5A4099F0bf6c8bC4252eBeC548Bae95602Ea]
        // rapperId = oneShot.getNextTokenId() - 1;
        oneShot.approve(address(rapBattle), 0); // address to, uint256 tokenId
        cred.approve(address(rapBattle), defenderBet);

        rapBattle.goOnStageOrBattle(0, defenderBet); // ID, _credBet amount uint256 _tokenId, uint256 _credBet
        vm.stopPrank();
    }

    function stake() public {
        if (oneShot.ownerOf(0) == user) {
            vm.startPrank(user);
            oneShot.approve(address(streets), 0);
            streets.stake(0);
            vm.stopPrank();
        } else if (oneShot.ownerOf(1) == user) {
            vm.startPrank(user);
            oneShot.approve(address(streets), 1);
            streets.stake(1);
            vm.stopPrank();
        } else {
            console.log("no one owns tokenId 0 or 1");
        }
    }

    function unStake() public {
        (, address owner) = streets.stakes(0);
        if (owner == address(streets)) {
            // if id`0` is being staked
            vm.warp(4 days + 1);
            vm.startPrank(user);
            streets.unstake(0);
            vm.stopPrank();
        } else if (owner == address(user)) {
            // only unstake if id`0` is being staked
            return;
        } else {
            console.log("unstake: no one owns tokenId 0");
        }
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
