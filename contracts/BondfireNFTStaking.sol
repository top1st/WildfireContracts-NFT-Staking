// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IBondfireStake.sol";
import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";


contract BondfireNFTStaking is Initializable, UUPSUpgradeable, Ownable {
    IERC20 public constant btc =
        IERC20(0xb17D901469B9208B17d916112988A3FeD19b5cA1);
    IERC721 public constant nft =
        IERC721(0x18E84B96ac3c584Ec5ae2fc4731248aa7dE554b7);

    IBondfireStake public constant fireStake =
        IBondfireStake(0xefC7429973c2bf2d40E2589C4DE06D1F42255832);

    struct UserInfo {
        uint positionId;
        uint amount;
        uint rewardDebt;
        uint registerAt;
        uint endAt;
        uint reward;
        bool ended;
    }

    mapping(address => UserInfo) public userInfo;

    uint public totalUsers;
    uint public totalInStake;
    uint public accPerShare;
    uint public totalBtc;
    bool public autoIncrease;

    event RegisterUser(address indexed user, uint indexed positionId);
    event Deposit(address indexed user, uint indexed positionId, uint amount);
    event Withdraw(address indexed user, uint indexed positionId, uint amount);
    event Claim(address indexed user, uint indexed positionId, uint amount);

    function initialize() initializer public {
        _transferOwnership(msg.sender);
    }

    function registerPosition(uint positionId) external {
        nft.transferFrom(msg.sender, address(this), positionId);
        UserInfo storage user = userInfo[msg.sender];
        require(user.registerAt == 0, "Already Registered");
        (, uint unlockTime, uint amount, , , ) = fireStake.lockInfo(positionId);
        user.positionId = positionId;
        user.maxAmount = amount;
        user.endAt = unlockTime;
        user.registerAt = block.timestamp;
        emit RegisterUser(msg.sender, positionId);
        totalUsers += 1;
    }

    function setAutoIncrease(bool increase) external onlyOwner {
        autoIncrease = increase;
    }

    function addFunds(uint amount) external {
        require(amount >= 0, "!zero");
        btc.transferFrom(msg.sender, address(this), amount);
        _increaseShare(amount);
    }

    function _increaseShare(uint amount) internal {
        totalBtc += amount;
        if (totalInStake != 0) {
            if (accPerShare != 0) {
                accPerShare += (1e18 * amount) / totalInStake;
            } else {
                accPerShare = (1e18 * totalBtc) / totalInStake;
            }
        }
    }

    function withdrawAll() public {
        withdraw(userInfo[msg.sender].amount);
    }

    function withdraw(uint amount) public {
        UserInfo storage user = userInfo[msg.sender];
        require(amount <= user.amount, "Exceed amount");
        require(user.registerAt != 0, "!registered");
        if(user.amount != 0 && user.ended == false) {
            claim();
        }
        user.amount -= amount;
        totalInStake -= amount;
        fire.transfer(msg.sender, amount);
        emit Withdraw(msg.sender, user.positionId, amount);
    }

    function emergencyWithdraw() external {
        UserInfo storage user = userInfo[msg.sender];
        require(user.registerAt != 0, "!registered");
        totalInStake -= user.amount;
        fire.transfer(msg.sender, user.amount);
        nft.transferFrom(address(this), msg.sender, user.positionId);
        delete userInfo[msg.sender];
    }

    function closePosition() external {
        UserInfo storage user = userInfo[msg.sender];
        require(user.registerAt != 0, "Unregistered");
        if (user.amount != 0) {
            withdraw(user.amount);
        }
        nft.transferFrom(address(this), msg.sender, user.positionId);
        delete userInfo[msg.sender];
        totalUsers--;
    }

    function deposit(uint amount) external returns (uint reward) {
        UserInfo storage user = userInfo[msg.sender];
        require(user.registerAt != 0, "!registered");
        require(user.endAt >= block.timestamp, "!ended position");
        fire.transferFrom(msg.sender, address(this), amount);
        if (user.amount != 0) {
            // claim pending
            reward = (user.amount * accPerShare - user.rewardDebt) / 1e18;
            user.reward += reward;

            btc.transfer(msg.sender, reward);
        } 
        user.amount = user.amount + amount;
        user.rewardDebt = accPerShare * user.amount;
        totalInStake += amount;
        require(user.amount <= user.maxAmount, "Exceed MaxAmount");
        emit Deposit(msg.sender, user.positionId, amount);
    }

    function claimable(address account) external view returns (uint reward) {
        UserInfo storage user = userInfo[account];
        if(user.amount == 0) return 0;
        if(user.ended) return 0;
        reward = (user.amount * accPerShare - user.rewardDebt) / 1e18;
        if (reward != 0) {
            if (user.endAt >= block.timestamp) {
                // claim pending
            } else {
                uint extraFunds = (reward * (block.timestamp - user.endAt)) /
                    (block.timestamp - user.registerAt);
                reward = reward - extraFunds;
            }
        }
    }

    function claim() public returns (uint reward) {
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount != 0, "Nothing to claim");
        require(!user.ended, "!ended position");
        reward = (user.amount * accPerShare - user.rewardDebt) / 1e18;
        if (reward != 0) {
            user.rewardDebt = user.amount * accPerShare;
            if (user.endAt >= block.timestamp) {
                // claim pending
                user.reward += reward;
                btc.transfer(msg.sender, reward);
            } else {
                uint extraFunds = (reward * (block.timestamp - user.endAt)) /
                    (block.timestamp - user.registerAt);
                if (autoIncrease) {
                    _increaseShare(extraFunds);
                } else {
                    btc.transfer(owner(), extraFunds);
                }
                reward = reward - extraFunds;
                user.reward += reward;
                user.ended = true;
                btc.transfer(msg.sender, reward);
            }
            emit Claim(msg.sender, user.positionId, reward);
        }
    }

    function _resetStaking() external onlyOwner {
        require(nft.balanceOf(address(this)) == 0, "Pending clearance");
        accPerShare = 0;
        totalInStake = 0;
        totalBtc = btc.balanceOf(address(this));
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}
}
