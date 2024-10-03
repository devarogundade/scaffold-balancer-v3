// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.24;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { IBasePoolFactory } from "@balancer-labs/v3-interfaces/contracts/vault/IBasePoolFactory.sol";
import { IHooks } from "@balancer-labs/v3-interfaces/contracts/vault/IHooks.sol";
import { IRouterCommon } from "@balancer-labs/v3-interfaces/contracts/vault/IRouterCommon.sol";
import { IVault } from "@balancer-labs/v3-interfaces/contracts/vault/IVault.sol";
import {
    LiquidityManagement,
    TokenConfig,
    PoolSwapParams,
    HookFlags
} from "@balancer-labs/v3-interfaces/contracts/vault/VaultTypes.sol";

import { VaultGuard } from "@balancer-labs/v3-vault/contracts/VaultGuard.sol";
import { BaseHooks } from "@balancer-labs/v3-vault/contracts/BaseHooks.sol";

import { LiquidityContest } from "./incentivized-pool/LiquidityContest.sol";

contract ReferralIncentivizedHook is BaseHooks, VaultGuard {
    using FixedPoint for uint256;

    // Only pools from a specific factory are able to register and use this hook.
    address private immutable _allowedFactory;
    // Only trusted routers are allowed to call this hook, because the hook relies on the `getSender` implementation
    // implementation to work properly.
    address private immutable _trustedRouter;

    ILiquidityContest private _liquidityContest;

    event ReferralIncentivizedHookRegistered(
        address indexed hooksContract,
        address indexed factory,
        address indexed pool
    );

    constructor(IVault vault, address allowedFactory, address trustedRouter) VaultGuard(vault) {
        _allowedFactory = allowedFactory;
        _trustedRouter = trustedRouter;

        _liquidityContest = new LiquidityContest();
    }

    function getHookFlags() public pure override returns (HookFlags memory hookFlags) {
        hookFlags.shouldCallAfterAddLiquidity = true;
        hookFlags.shouldCallAfterRemoveLiquidity = true;
    }

    function onRegister(
        address factory,
        address pool,
        TokenConfig[] memory,
        LiquidityManagement calldata
    ) public override onlyVault returns (bool) {
        emit ReferralIncentivizedHookRegistered(address(this), factory, pool);

        // Register the pool tokens with the liquidity contest mechanism.
        _liquidityContest.afterRegister(_vault.getPoolTokens(pool));

        return factory == _allowedFactory && IBasePoolFactory(factory).isPoolFromFactory(pool);
    }

    function onAfterAddLiquidity(
        address router,
        address pool,
        AddLiquidityKind,
        uint256[] memory,
        uint256[] memory amountsInRaw,
        uint256 bptAmountOut,
        uint256[] memory balancesScaled18,
        bytes memory
    ) external returns (bool success, uint256[] memory hookAdjustedAmountsInRaw) {
        address user = IRouterCommon(router).getSender();

        // Update the user's liquidity contest snapshot after adding liquidity.
        _liquidityContest.afterAddLiquidity(user, bptAmountOut, balancesScaled18);

        return (true, amountsInRaw);
    }

    function onAfterRemoveLiquidity(
        address router,
        address pool,
        RemoveLiquidityKind,
        uint256 bptAmountIn,
        uint256[] memory,
        uint256[] memory amountsOutRaw,
        uint256[] memory balancesScaled18,
        bytes memory
    ) external returns (bool success, uint256[] memory hookAdjustedAmountsOutRaw) {
        address user = IRouterCommon(router).getSender();

        // Update the user's liquidity contest snapshot after removing liquidity and process rewards.
        _liquidityContest.afterRemoveLiquidity(user, bptAmountIn, balancesScaled18);

        return (true, amountsOutRaw);
    }
}
