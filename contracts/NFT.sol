// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@limitbreak/creator-token-contracts/contracts/erc721c/ERC721C.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IERC4907.sol";


contract NFT is ERC721C, Ownable, IERC4907 {
        
    struct UserInfo 
    {
        address user;   // address of user role
        uint64 expires; // unix timestamp, user expires
    }

    mapping (uint256  => UserInfo) internal _users;

    string public baseUrl;
    address public minter;

    constructor() ERC721OpenZeppelin("NFT", "NFT") {}

    function _requireCallerIsContractOwner() internal view virtual override {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    // NFT Sales contracts can call this function to mint NFTs
    function mint(uint256 tokenId, address to) public  {
        require(_msgSender() == minter, "only minter");
        _mint(to, tokenId);
    }

    function setMinter(address minter_) public onlyOwner {
        minter = minter_;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseUrl;
    }

    function setBaseUrl(string calldata url_) public onlyOwner {
        baseUrl = url_;
    }

    /// @notice set the user and expires of a NFT
    /// @dev The zero address indicates there is no user 
    /// Throws if `tokenId` is not valid NFT
    /// @param user  The new user of the NFT
    /// @param expires  UNIX timestamp, The new user could use the NFT before expires
    function setUser(uint256 tokenId, address user, uint64 expires) public virtual{
        require(_isApprovedOrOwner(msg.sender, tokenId),"ERC721: transfer caller is not owner nor approved");
        UserInfo storage info =  _users[tokenId];
        info.user = user;
        info.expires = expires;
        emit UpdateUser(tokenId,user,expires);
    }

    /// @notice Get the user address of an NFT
    /// @dev The zero address indicates that there is no user or the user is expired
    /// @param tokenId The NFT to get the user address for
    /// @return The user address for this NFT
    function userOf(uint256 tokenId)public view virtual returns(address){
        if( uint256(_users[tokenId].expires) >=  block.timestamp){
            return  _users[tokenId].user; 
        }
        else{
            return address(0);
        }
    }

    /// @notice Get the user expires of an NFT
    /// @dev The zero value indicates that there is no user 
    /// @param tokenId The NFT to get the user expires for
    /// @return The user expires for this NFT
    function userExpires(uint256 tokenId) public view virtual returns(uint256){
        return _users[tokenId].expires;
    }

    /// @dev See {IERC165-supportsInterface}.
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC4907).interfaceId || super.supportsInterface(interfaceId);
    }


    /// @dev See {ERC721-_burn}. This override additionally clears the user information for the token.
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);
        delete _users[tokenId];
        emit UpdateUser(tokenId, address(0), 0);
    }
}
