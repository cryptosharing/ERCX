// SPDX-License-Identifier: MIT


pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import "./interface/IERC9999.sol";

/// @title cryptosharing
/// @author libo
/// @notice cryptosharing
contract ERC9999 is IERC9999 , ERC721 {
    
    // Mapping from token ID to user address
    mapping(uint256 => address) private _users;

    // Mapping user address to token count
    mapping(address => uint256) private _balancesOfUser;
    
    constructor(string memory name_, string memory symbol_) ERC721(name_ , symbol_){
        
    }
    
    function balanceOfUser(address user) public view virtual override returns (uint256) {
        require(user != address(0), "ERC9999: balance query for the zero address");
        return _balancesOfUser[user];
    }
    
    function userOf(uint256 tokenId) public view virtual override returns (address) {
        address user = _users[tokenId];
        require(user != address(0), "ERC9999: user query for nonexistent token");
        return user;
    }
    
    function transferUserFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrUser(_msgSender(), tokenId), "ERC9999: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }
    
    function safeTransferUserFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferUserFrom(from, to, tokenId, "");
    }
    
    function safeTransferUserFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrUser(_msgSender(), tokenId), "ERC9999: transfer caller is not owner nor approved");
        _safeTransferUser(from, to, tokenId, _data);
    }
    
    function _isApprovedOrUser(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(ERC721._exists(tokenId), "ERC9999: operator query for nonexistent token");
        address user = ERC9999.userOf(tokenId);
        address owner = super.ownerOf(tokenId);
        return (spender == user || spender == owner);
    }
    
    function _safeTransferUser(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transferUser(from, to, tokenId);
    }
    
    function _transferUser(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC9999.userOf(tokenId) == from, "ERC9999: transfer of token that is not use");
        require(to != address(0), "ERC9999: transfer to the zero address");

        _beforeTokenTransferUser(from, to, tokenId);

        // Clear approvals from the previous owner
        //_approve(address(0), tokenId);

        _balancesOfUser[from] -= 1;
        _balancesOfUser[to] += 1;
        _users[tokenId] = to;

        emit TransferUser(from, to, tokenId);
    }
    
    function _mint(address to , uint256 tokenId) override internal virtual{
        require(to != address(0), "ERC9999: mint to the zero address");

        _beforeTokenTransferUser(address(0), to, tokenId);

        _balancesOfUser[to] += 1;
        _users[tokenId] = to;
        super._safeMint(to,tokenId);
    }
    
    function _beforeTokenTransferUser(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
    
}
