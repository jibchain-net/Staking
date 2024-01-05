// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error ZeroAmount();
error ZeroAddress();
error AccessIsDenied();
error NotEnded();
error NotContract();
error AlreadyAssigned();
error Recover();

contract Staking is Ownable, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;

    IERC20 public immutable rewardsToken;
    IERC20 public immutable stakingToken;
    uint256 public periodFinish;
    uint256 public rewardRate;
    uint256 public rewardsDuration;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardsDurationUpdated(uint256 indexed newDuration);
    event Recovered(address indexed token, address indexed recipient, uint256 amount);

    constructor(address _rewardsToken, address _stakingToken, uint256 _sec, address _admin) Ownable(_admin) {
        rewardsToken = IERC20(_rewardsToken);
        stakingToken = IERC20(_stakingToken);
        rewardsDuration = _sec;
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    function stake(uint256 amount) external nonReentrant whenNotPaused {
        _stake(msg.sender, amount);
    }

    function stakeFor(address user, uint256 amount) external nonReentrant whenNotPaused {
        _stake(user, amount);
    }

    function withdraw(uint256 amount) external nonReentrant whenNotPaused {
        _withdraw(msg.sender, amount);
    }

    function claimReward() external nonReentrant whenNotPaused {
        _claimReward(msg.sender);
    }

    function exit() external whenNotPaused nonReentrant {
        _withdraw(msg.sender, balanceOf[msg.sender]);
        _claimReward(msg.sender);
    }

    function notifyRewardAmount(uint256 reward) external onlyOwner updateReward(address(0)) {
        rewardsToken.safeTransferFrom(msg.sender, address(this), reward);
        if (block.timestamp >= periodFinish) {
            rewardRate = reward / rewardsDuration;
        } else {
            uint256 remaining = periodFinish - block.timestamp;
            uint256 leftover = remaining * rewardRate;
            rewardRate = (reward + leftover) / rewardsDuration;
        }

        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp + rewardsDuration;

        emit RewardAdded(reward);
    }

    function recoverERC20(address tokenAddress, uint256 tokenAmount, address recipient) external onlyOwner {
        if (recipient == address(0) || tokenAddress == address(0)) {
            revert ZeroAddress();
        }
        if (tokenAmount == 0) {
            revert ZeroAmount();
        }
        if (tokenAddress == address(stakingToken) || tokenAddress == address(rewardsToken)) {
            revert Recover();
        }
        IERC20(tokenAddress).safeTransfer(recipient, tokenAmount);
        emit Recovered(tokenAddress, recipient, tokenAmount);
    }

    function setRewardsDuration(uint256 _rewardsDuration) external onlyOwner {
        if (block.timestamp < periodFinish) {
            revert NotEnded();
        }
        rewardsDuration = _rewardsDuration;
        emit RewardsDurationUpdated(rewardsDuration);
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return block.timestamp < periodFinish ? block.timestamp : periodFinish;
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return rewardPerTokenStored
            + ((((lastTimeRewardApplicable() - lastUpdateTime) * rewardRate) * 1e18) / totalSupply);
    }

    function earned(address account) public view returns (uint256) {
        return (balanceOf[account] * (rewardPerToken() - userRewardPerTokenPaid[account])) / 1e18 + rewards[account];
    }

    function getRewardForDuration() external view returns (uint256) {
        return rewardRate * rewardsDuration;
    }

    function _stake(address user, uint256 amount) internal updateReward(user) {
        if (amount == 0) {
            revert ZeroAmount();
        }
        if (user == address(0)) {
            revert ZeroAddress();
        }
        totalSupply += amount;
        balanceOf[user] += amount;
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        emit Staked(user, amount);
    }

    function _withdraw(address user, uint256 amount) internal updateReward(user) {
        if (amount == 0) {
            revert ZeroAmount();
        }
        totalSupply -= amount;
        balanceOf[user] -= amount;
        stakingToken.safeTransfer(user, amount);
        emit Withdrawn(user, amount);
    }

    function _claimReward(address user) internal updateReward(user) {
        uint256 reward = rewards[user];
        if (reward > 0) {
            rewards[user] = 0;
            rewardsToken.safeTransfer(user, reward);
            emit RewardPaid(user, reward);
        }
    }
}
