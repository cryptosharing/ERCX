// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERCX.sol";

/*
 *@title a interface for ERCXEnumerable.
 *@dev enumerable NFT include user and owner.
 *@author 
 */
interface IERCXEnumerable is IERCX {

    /**
     * @dev enumerate the user token list. Use along with {ERCX.balanceOfUser} to enumerate all of ``user``'s tokens.
     * @param user the address of token user.
     * @param index the index of user token list.
     * @return tokenId used by `user` at a given `index` of its token list.
     */
    function tokenOfUserByIndex(address user, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev get the total amount of tokens stored by the contract.
     * @return the total amount of tokens stored by the contract.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev enumerate the owner token list.
     * @param owner the address of token owner.
     * @param index the index of owner token list.
     * return a token ID owned by `owner` at a given `index` of its token list.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);

    /**
     * @dev get a tokenId through index of contract token list.
     * @param index the index of contract token list.
     * @return a tokenId at a given `index` of all the tokens stored by the contract.
     */
    function tokenByIndex(uint256 index) external view returns (uint256);
}
