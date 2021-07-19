// SPDX-License-Identifier: NO LICENSE
pragma solidity 0.7.6;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract ENERGY is ERC20Burnable {
  using SafeMath for uint256;

  uint256 public constant initialSupply = 89099136 * 10 ** 3;
  uint256 public lastWeekTime;
  uint256 public weekCount;
  //staking start when week count set to 1 -> rewards calculated before just updating week
  uint256 public constant totalWeeks = 100;
  address public stakingContrAddr;
  address public liquidityContrAddr;
  uint256 public constant timeStep = 1 weeks;
  
  modifier onlyStaking() {
    require(_msgSender() == stakingContrAddr, "Not staking contract");
    _;
  }

  constructor (address _liquidityContrAddr) ERC20("ENERGY", "NRGY") {
    //89099.136 coins
    _setupDecimals(6);
    lastWeekTime = block.timestamp;
    liquidityContrAddr = _liquidityContrAddr;
    _mint(_msgSender(), initialSupply.mul(4).div(10)); //40%
    _mint(liquidityContrAddr, initialSupply.mul(6).div(10)); //60%
  }

  function mintNewCoins(uint256[3] memory lastWeekRewards) public onlyStaking returns(bool) {
    if(weekCount >= 1) {
        uint256 newMint = lastWeekRewards[0].add(lastWeekRewards[1]).add(lastWeekRewards[2]);
        uint256 liquidityMint = (newMint.mul(20)).div(100);
        _mint(liquidityContrAddr, liquidityMint);
        _mint(stakingContrAddr, newMint);
    } else {
        _mint(liquidityContrAddr, initialSupply);
    }
    return true;
  }

  //updates only at end of week
  function updateWeek() public onlyStaking {
    weekCount++;
    lastWeekTime = block.timestamp;
  }

  function updateStakingContract(address _stakingContrAddr) public {
    require(stakingContrAddr == address(0), "Staking contract is already set");
    stakingContrAddr = _stakingContrAddr;
  }

  function burnOnUnstake(address account, uint256 amount) public onlyStaking {
      _burn(account, amount);
  }

  function getLastWeekUpdateTime() public view returns(uint256) {
    return lastWeekTime;
  }

  function isMintingCompleted() public view returns(bool) {
    if(weekCount > totalWeeks) {
      return true;
    } else {
      return false;
    }
  }

  function isGreaterThanAWeek() public view returns(bool) {
    if(block.timestamp > getLastWeekUpdateTime().add(timeStep)) {
      return true;
    } else {
      return false;
    }
  }
}