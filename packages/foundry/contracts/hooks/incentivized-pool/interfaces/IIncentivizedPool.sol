// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.24;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title IIncentivizedPool
 * @dev Interface for the IncentivizedPool contract which outlines the key functions and structures
 *      needed for managing incentized pools with snapshot-based reward distribution.
 */
interface IIncentivizedPool {
    /**
     * @dev Snapshot structure to track user's liquidity position.
     * @param bptAmount Amount of pool tokens (BPT) representing the user's share in the pool.
     * @param bptTotalSupply Total supply of pool tokens at the time of snapshot creation.
     * @param balancesScaled18 Array representing the balances of the underlying pool assets, scaled to 18 decimals.
     */
    struct Snapshot {
        uint256 bptAmount; // Amount of pool tokens (BPT) user holds in the pool
        uint256 bptTotalSupply; // Total supply of BPT at the time of the snapshot
        uint256[] balancesScaled18; // Balances of underlying pool assets, scaled to 18 decimals
    }

    /**
     * @notice Registers the pool tokens that will be used in the incentized pool.
     * @dev This function is intended to be called by the owner of the contract.
     * @param tokens Array of IERC20 tokens that are part of the liquidity pool.
     */
    function afterRegister(IERC20[] memory tokens) external;

    /**
     * @notice Called after a user adds liquidity to the pool. Records a snapshot of the user's position.
     * @dev This function should only be callable by the owner to maintain integrity.
     * @param user Address of the user who added liquidity.
     * @param bptAmountOut Amount of pool tokens (BPT) issued to the user as a result of adding liquidity.
     * @param balancesScaled18 Current balances of the underlying pool assets, scaled to 18 decimals.
     */
    function afterAddLiquidity(address user, uint256 bptAmountOut, uint256[] memory balancesScaled18) external;

    /**
     * @notice Called after a user removes liquidity from the pool. Processes and distributes rewards.
     * @dev This function should only be callable by the owner to ensure accurate reward calculations.
     * @param user Address of the user who removed liquidity.
     * @param bptAmountIn Amount of pool tokens (BPT) removed by the user.
     * @param balancesScaled18 Current balances of the underlying pool assets, scaled to 18 decimals.
     */
    function afterRemoveLiquidity(address user, uint256 bptAmountIn, uint256[] memory balancesScaled18) external;
}
