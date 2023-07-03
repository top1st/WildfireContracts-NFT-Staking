// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
interface IBondfireStake {
    // mapping(uint => LockInfo) public 
    function lockInfo(uint) external view returns (uint startTime, uint unlockTime, uint amount, uint claimAble, uint lpAmount, uint earlyWithdrawFee);
}
