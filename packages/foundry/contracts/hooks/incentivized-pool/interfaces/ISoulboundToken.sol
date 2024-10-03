// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.24;

/**
 * @title ISoulboundToken
 * @dev Interface for interacting with SoulboundToken contracts.
 *      It includes a function to retrieve a user's referrer.
 */
interface ISoulboundToken {
    /**
     * @dev Returns the referrer address for a given user.
     * @param user The address of the user.
     * @return The address of the referrer who referred the user.
     */
    function getReferral(address user) external view returns (address);
}
