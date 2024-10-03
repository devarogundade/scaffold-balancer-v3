// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.24;

import { ISoulboundToken } from "./interfaces/ISoulboundToken.sol";

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title SoulboundToken
 * @dev A non-transferable ERC721 token contract implementing soulbound tokens.
 *      Soulbound tokens are linked permanently to an address once minted and cannot be transferred or sold.
 */
contract SoulboundToken is ISoulboundToken, ERC721, Ownable {
    // Mapping from user address to token ID to track Soulbound tokens
    mapping(address => uint256) private _soulboundTokens;

    // Mapping from user address to referrer address
    mapping(address => address) private _referrers;

    // Token ID counter for new tokens
    uint256 private _nextTokenId;

    /**
     * @dev Constructor that sets the token name and symbol, and initializes the token ID counter.
     * @param name The name of the Soulbound token collection.
     * @param symbol The symbol representing the Soulbound token.
     */
    constructor(string memory name, string memory symbol) ERC721(name, symbol) Ownable() {
        _nextTokenId = 1; // Initialize the token counter
    }

    /**
     * @dev Mint a new Soulbound token to the caller. The token is non-transferable and linked permanently to the caller's address.
     * @param referrer The address of the referrer who referred the caller (optional).
     */
    function mint(address referrer) external {
        address sender = _msgSender();

        // Ensure that the caller does not already own a Soulbound token
        require(_soulboundTokens[sender] == 0, "SoulboundToken: Token already minted for this address");

        // Mint a new token to the caller
        _mint(sender, _nextTokenId);

        // Register the token as soulbound by associating it with the sender's address
        _soulboundTokens[sender] = _nextTokenId;

        // Store the referrer address if provided
        _referrers[sender] = referrer;

        // Increment the token ID counter for the next mint
        _nextTokenId++;
    }

    /**
     * @dev Mint a new Soulbound token to a specified user. The token is non-transferable and linked permanently to the user's address.
     * @param user The address of the user to mint the token for.
     * @param referrer The address of the referrer who referred the user (optional).
     */
    function mintTo(address user, address referrer) external onlyOwner {
        // Ensure that the user does not already own a Soulbound token
        require(_soulboundTokens[user] == 0, "SoulboundToken: Token already minted for this address");

        // Mint a new token to the user
        _mint(user, _nextTokenId);

        // Register the token as soulbound by associating it with the user's address
        _soulboundTokens[user] = _nextTokenId;

        // Store the referrer address if provided
        _referrers[user] = referrer;

        // Increment the token ID counter for the next mint
        _nextTokenId++;
    }

    /**
     * @dev Get the referrer address for a specific user.
     * @param user The address of the user.
     * @return The address of the user's referrer.
     */
    function getReferral(address user) external view returns (address) {
        return _referrers[user];
    }

    // ========= OVERRIDE NFT TRANSFER FUNCTIONS ========= //

    /**
     * @dev Override the ERC721 `transferFrom` function to prevent the transfer of Soulbound tokens.
     * @notice Soulbound tokens are non-transferable, and any attempt to transfer will be blocked.
     * @param from The address sending the token.
     * @param to The address receiving the token.
     * @param tokenId The token ID being transferred.
     */
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        require(_soulboundTokens[from] != 0, "SoulboundToken: Token is non-transferable");
        revert("SoulboundToken: Transfers are not allowed for soulbound tokens");
    }

    /**
     * @dev Override the ERC721 `safeTransferFrom` function to prevent the safe transfer of Soulbound tokens.
     * @notice Soulbound tokens are non-transferable, and any attempt to transfer will be blocked.
     * @param from The address sending the token.
     * @param to The address receiving the token.
     * @param tokenId The token ID being transferred.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        require(_soulboundTokens[from] != 0, "SoulboundToken: Token is non-transferable");
        revert("SoulboundToken: Transfers are not allowed for soulbound tokens");
    }

    /**
     * @dev Override the ERC721 `safeTransferFrom` function (with data) to prevent the safe transfer of Soulbound tokens.
     * @notice Soulbound tokens are non-transferable, and any attempt to transfer will be blocked.
     * @param from The address sending the token.
     * @param to The address receiving the token.
     * @param tokenId The token ID being transferred.
     * @param _data Additional data with no specified format.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public virtual override {
        require(_soulboundTokens[from] != 0, "SoulboundToken: Token is non-transferable");
        revert("SoulboundToken: Transfers are not allowed for soulbound tokens");
    }

    /**
     * @dev Burn (destroy) a Soulbound token. This function is restricted to the contract owner.
     * @notice This allows the contract owner to destroy a specific token and clean up the soulbound status.
     * @param user The address of the user whose token is to be burned.
     */
    function burn(address user) external onlyOwner {
        uint256 tokenId = _soulboundTokens[user];

        _burn(tokenId); // Burn the token
        delete _soulboundTokens[user]; // Remove the token from the soulbound mapping
    }

    /**
     * @dev Check if a user has a Soulbound token (non-transferable).
     * @param user The address of the user.
     * @return True if the user has a soulbound token, otherwise false.
     */
    function isSoulbound(address user) external view returns (bool) {
        return _soulboundTokens[user] != 0;
    }
}
