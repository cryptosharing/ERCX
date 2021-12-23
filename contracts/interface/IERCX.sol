// SPDX-License-Identifier: MIT


pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @title a interface of ERCX
 * @author 
 * @dev Required interface of an ERCX compliant contract.
 */
interface IERCX is IERC721{

    /**
     * @dev Emitted when `tokenId` tokenUser is transferred from `from` to `to`.
     */    
    event TransferUser(address from,address to,uint256 tokenId);
    
    /**
     * @dev Emitted when `user` enables `approved` to manage the `tokenId` tokenUser.
     */ 
    event ApprovalUser(address indexed user, address indexed approved, uint256 indexed tokenId);
    
    /**
     * @dev Returns the number of usable token in ``user``'s account.
     */    
    function balanceOfUser(address user) external view returns (uint256 balance);
    
    /**
     * @dev Returns the user of tokenId token
     * @param tokenId the NFT token's Id 
     * @return user the address of token user
     */    
    function userOf(uint256 tokenId) external view returns (address user);
    
    /**
     * @notice Safely transfers `tokenId` tokenUser from `from` to `to`
     * @dev If the caller is not `from`, it must be approved to move this tokenUser by {approve} or {setApprovalForAll} or {approveUser}.
     * @param from the address token user transfer from
     * @param to the address token user transfer to
     * @param tokenId the NFT token's Id
     */    
    function safeTransferUserFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    
    /**
     * @notice Safely transfers `tokenId` tokenUser from `from` to `to`
     * @dev If the caller is not `from`, it must be approved to move this tokenUser by {approve} or {setApprovalForAll} or {approveUser}.
     * @param from the address token user transfer from
     * @param to the address token user transfer to
     * @param tokenId the NFT token's Id
     * @param data caller want to add extra information
     */  
    function safeTransferUserFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
    
    /**
     * @notice Safely transfers `tokenId` token and tokenUser from `from` to `to`
     * @dev If the caller is not `from`, it must be approved to move this tokenUser by {approve} or {setApprovalForAll} or {approveUser}.
     * @param from the address token and its user transfer from
     * @param to the address token and its user transfer to
     * @param tokenId the NFT token's Id
     */
    function safeTransferAllFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    
    /**
     * @notice Safely transfers `tokenId` token and tokenUser from `from` to `to`
     * @dev If the caller is not `from`, it must be approved to move this tokenUser by {approve} or {setApprovalForAll} or {approveUser}.
     * @param from the address token and its user transfer from
     * @param to the address token and its user transfer to
     * @param tokenId the NFT token's Id
     * @param data caller want to add extra information
     */
    function safeTransferAllFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
    
    /**
     * @notice Gives permission to `to` to transfer `tokenId` tokenUser to another account.
     * @dev Only a single account can be approved at a time, so approving the zero address clears previous approvals.The caller must be tokenUser or be an approvedUser operator.The approval is cleared when the tokenUser is transferred.
     * @param to the approved address 
     * @param tokenId the NFT token's Id
     */
    function approveUser(address to, uint256 tokenId) external;
    
    /**
     * @dev Returns the approvedUser for `tokenId` token.
     * @param tokenId the NFT token's Id
     * @return operator the approved address
     */
    function getApprovedUser(uint256 tokenId) external view returns (address operator);
    
    
}
