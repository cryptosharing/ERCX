// SPDX-License-Identifier: MIT


pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import "./interface/IERC9999.sol";

/// @title cryptosharing
/// @author Kimos
/// @notice cryptosharing

contract ERC9999 is IERC9999 , ERC721 {
    
    // Mapping from token ID to user address
    mapping(uint256 => address) private _users;

    // Mapping user address to token count
    mapping(address => uint256) private _balancesOfUser;
    
     // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenUserApprovals;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) ERC721(name_ , symbol_){
        
    }
    
    /*
     *@dev see{IERC9999-approveUser}
     */
    function approveUser(address to, uint256 tokenId) public virtual override{
        address user = ERC9999.userOf(tokenId);
        require(to != user, "ERC9999: approval to current user");

        require(
            _isApprovedOrOwner(_msgSender(), tokenId) || _isApprovedOrUser(_msgSender(), tokenId),
            "ERC9999: approve caller is not owner nor approved for all"
        );

        _approveUser(to, tokenId);
    }
    
    /**
     * @dev Approve `to` to operate on `tokenId` token use right.
     *
     * Emits a {ApprovalUser} event.
     */
    function _approveUser(address to, uint256 tokenId) internal virtual {
        _tokenUserApprovals[tokenId] = to;
        emit ApprovalUser(ERC721.ownerOf(tokenId), to, tokenId);
    }
    
    /*
     *@dev see{IERC9999-getApprovedUser}
     */
    function getApprovedUser(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC9999: approved query for nonexistent token");

        return _tokenUserApprovals[tokenId];
    }
    
    /*
     *@dev see{IERC9999-balanceOfUser}
     */
    function balanceOfUser(address user) public view virtual override returns (uint256) {
        require(user != address(0), "ERC9999: balance query for the zero address");
        return _balancesOfUser[user];
    }
    
    /*
     *@dev see{IERC9999-userOf}
     */
    function userOf(uint256 tokenId) public view virtual override returns (address) {
        address user = _users[tokenId];
        require(user != address(0), "ERC9999: user query for nonexistent token");
        return user;
    }
    
    /*
     *@dev see{IERC9999-safeTranserUserFrom}
     */
    function safeTransferUserFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferUserFrom(from, to, tokenId, "");
    }
    
    /*
     *@dev see{IERC9999-safeTransferUserFrom}
     */
    function safeTransferUserFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrUser(_msgSender(), tokenId) || _isApprovedOrOwner(_msgSender(),tokenId), "ERC9999: transfer caller is not user or owner nor approved");
        _safeTransferUser(from, to, tokenId, _data);
    }

    /*
     *@dev see{IERC9999-safeTransfferAllFrom}
     */
    function safeTransferAllFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferAllFrom(from, to, tokenId, "");
    }
    
    /*
     *@dev see{IERC9999-safeTransferAllFrom}
     */
    function safeTransferAllFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(),tokenId),"ERC9999: transfer caller is not owner nor approved");
        safeTransferUserFrom(from, to, tokenId, "");
        safeTransferFrom(from, to, tokenId, "");
    }
    
    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId` token use right.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrUser(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(ERC721._exists(tokenId), "ERC9999: operator query for nonexistent token");
        address user = ERC9999.userOf(tokenId);
        return (spender == user || getApprovedUser(tokenId) == user);
    }
    
    /**
     * @dev Safely transfers `tokenId` token use right from `from` to `to`
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be used/owned or approved/user-approved by `from`.
     *
     * Emits a {TransferUser} event.
     */
    function _safeTransferUser(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transferUser(from, to, tokenId);
    }
    
    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be used/owned or approved/user-approved by `from`.
     *
     * Emits a {TransferUser} event.
     */
    function _transferUser(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC9999.userOf(tokenId) == from || ERC721.ownerOf(tokenId) == from, "ERC9999: transfer of token that is not use");
        require(to != address(0), "ERC9999: transfer to the zero address");
        address user = userOf(tokenId);
        _beforeTokenTransferUser(user, to, tokenId);

        // Clear approvals from the previous owner
        _approveUser(address(0), tokenId);
        
        _balancesOfUser[user] -= 1;
        _balancesOfUser[to] += 1;
        _users[tokenId] = to;

        emit TransferUser(from, to, tokenId);
    }
    
    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} and a {TransferUser} event.
     */
    function _safeMint(address to , uint256 tokenId) internal virtual override{
        require(to != address(0), "ERC9999: mint to the zero address");

        _beforeTokenTransferUser(address(0), to, tokenId);

        _balancesOfUser[to] += 1;
        _users[tokenId] = to;
        super._safeMint(to,tokenId);
        emit TransferUser(address(0), to, tokenId);
    }
    
    /**
     * @dev Destroys `tokenId` token and its use right.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {TransferUser} and a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual override{
        super._burn();

        address user = userOf(tokenId);

        _beforeTokenTransferUser(user, address(0), tokenId);
        // Clear approvals
        _approveUser(address(0), tokenId);

        _balancesOfUser[user] -= 1;
        delete _users[tokenId];

        emit TransferUser(user, address(0), tokenId);
    }

    /**
     * @dev Hook that is called before any tokenUser transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` token use right will be
     * transferred to `to`.
     *
     */
    function _beforeTokenTransferUser(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
    
}
