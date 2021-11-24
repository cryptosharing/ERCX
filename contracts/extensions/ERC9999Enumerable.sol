// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../ERC9999.sol";
import "./IERC9999Enumerable.sol";

 contract ERC9999Enumerable is ERC9999 ,IERC9999Enumerable{
    // Mapping from user to list of useable token IDs
    mapping(address => mapping(uint256 => uint256)) private _userTokens;

    // Mapping from token ID to index of the user tokens list
    mapping(uint256 => uint256) private _userTokensIndex;
    
    constructor(string memory name_, string memory symbol_) ERC9999(name_ , symbol_){
        
    }
    
    /**
     * @dev to get the tokenid of user by index,
     */
    function tokenOfUserByIndex(address user, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC9999.balanceOfUser(user), "ERC9999Enumerable: user index out of bounds");
        return _userTokens[user][index];
    }
    
    /**
     * @dev Private function to add a token to this extension's usership-tracking data structures.
     * @param to address representing the new user of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToUserEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC9999.balanceOfUser(to);
        _userTokens[to][length] = tokenId;
        _userTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to remove a token from this extension's usership-tracking data structures. Note that
     * while the token is not assigned a new user, the `_userTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _userTokens array.
     * @param from address representing the previous user of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromUserEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = ERC9999.balanceOfUser(from) - 1;
        uint256 tokenIndex = _userTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _userTokens[from][lastTokenIndex];

            _userTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _userTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _userTokensIndex[tokenId];
        delete _userTokens[from][lastTokenIndex];
    }

    function _beforeTokenTransferUser(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransferUser(from, to, tokenId);
        if(from != address(0)){
            _removeTokenFromUserEnumeration(from, tokenId);
        }
        _addTokenToUserEnumeration(to, tokenId);
    }
}
