// SPDX-License-Identifier: MIT


pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721.sol";

/**
 * @dev Required interface of an ERC9999 compliant contract.
 */
interface IERC9999 is IERC721{

    /**
     * @dev Emitted when `tokenId` use right is transferred from `from` to `to`.
     */    
    event TransferUser(address from,address to,uint256 tokenId);
    
    /**
     * @dev Emitted when `user` enables `approved` to manage the `tokenId` use right.
     */ 
     //有必要吗
    event ApprovalUser(address indexed user, address indexed approved, uint256 indexed tokenId);
    
    /**
     * @dev Returns the number of usable token in ``user``'s account.
     */    
    function balanceOfUser(address user) external view returns (uint256 balance);
    
    /**
     * @dev Returns the user of tokenId token
     * Requirements:
     *
     * - `tokenId` must exist.
     */    
    function userOf(uint256 tokenId) external view returns (address user);
    
    /**
     * @dev Safely transfers `tokenId` user right from `from` to `to`
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be used/owned or by {approveUser}/{approve}/{setApprovalForAll} by `from`.
     *
     * Emits a {TransferUser} event.
     */    
    function safeTransferUserFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    
    /**
     * @dev Safely transfers `tokenId` user right from `from` to `to`
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be used/owned or approved/user-approved by `from`.
     *
     * Emits a {TransferUser} event.
     */  
    function safeTransferUserFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
    
    /**
     * @dev Safely transfers `tokenId` token and user right from `from` to `to`
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned or by {approve}/{setApprovalForAll} by `from`.
     *
     * Emits a {Transfer} and {TransferUser} event.
     */
    function safeTransferAllFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    
    /**
     * @dev Safely transfers `tokenId` token and user right from `from` to `to`
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned or by {approve}/{setApprovalForAll} by `from`.
     *
     * Emits a {Transfer} and {TransferUser} event.
     */
    function safeTransferAllFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
    
    /**
     * @dev Gives permission to `to` to transfer `tokenId` user to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token use right or be an user-approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {ApprovalUser} event.
     */
    function approveUser(address to, uint256 tokenId) external;
    
    /**
     * @dev Returns the account user-approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApprovedUser(uint256 tokenId) external view returns (address operator);
    
    
}
