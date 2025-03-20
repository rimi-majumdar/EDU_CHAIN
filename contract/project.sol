// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DonationNFT {
    // State Variables
    string public name = "DonationNFT";
    string public symbol = "DNFT";
    uint256 public nextTokenId;
    address public donationAddress;
    uint256 public donationPercentage; // Percentage of sale to donate (e.g., 10 for 10%)

    // Mappings
    mapping(uint256 => address) private _owners;
    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => uint256) public tokenPrices;
    mapping(uint256 => address) public tokenSellers;

    // Events
    event NFTMinted(uint256 tokenId, address owner, string tokenURI);
    event NFTPurchased(uint256 tokenId, address buyer, uint256 price);
    event NFTListed(uint256 tokenId, address seller, uint256 price);

    // Modifiers
    modifier onlyOwner(uint256 tokenId) {
        require(_owners[tokenId] == msg.sender, "Not the token owner");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == donationAddress, "Only admin can call this");
        _;
    }

    // Constructor
    constructor(address _donationAddress, uint256 _donationPercentage) {
        require(_donationPercentage <= 100, "Invalid donation percentage");
        donationAddress = _donationAddress;
        donationPercentage = _donationPercentage;
    }

    // Minting Function
    function mintNFT(string memory tokenURI) public {
        uint256 tokenId = nextTokenId;
        _owners[tokenId] = msg.sender;
        _tokenURIs[tokenId] = tokenURI;
        nextTokenId++;

        emit NFTMinted(tokenId, msg.sender, tokenURI);
    }

    // Listing Function
    function listNFT(uint256 tokenId, uint256 price) public onlyOwner(tokenId) {
        require(price > 0, "Price must be greater than zero");
        tokenPrices[tokenId] = price;
        tokenSellers[tokenId] = msg.sender;

        emit NFTListed(tokenId, msg.sender, price);
    }

    // Buying Function
    function buyNFT(uint256 tokenId) public payable {
        uint256 price = tokenPrices[tokenId];
        require(price > 0, "NFT not for sale");
        require(msg.value == price, "Incorrect payment amount");

        address seller = tokenSellers[tokenId];
        uint256 donationAmount = (price * donationPercentage) / 100;
        uint256 sellerAmount = price - donationAmount;

        // Transfer payment
        payable(seller).transfer(sellerAmount);
        payable(donationAddress).transfer(donationAmount);

        // Transfer ownership
        _owners[tokenId] = msg.sender;
        delete tokenPrices[tokenId];
        delete tokenSellers[tokenId];

        emit NFTPurchased(tokenId, msg.sender, price);
    }

    // Admin Functions
    function setDonationAddress(address _donationAddress) public onlyAdmin {
        donationAddress = _donationAddress;
    }

    function setDonationPercentage(uint256 _donationPercentage) public onlyAdmin {
        require(_donationPercentage <= 100, "Invalid donation percentage");
        donationPercentage = _donationPercentage;
    }

    // Getter Functions
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_owners[tokenId] != address(0), "Token does not exist");
        return _tokenURIs[tokenId];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        require(_owners[tokenId] != address(0), "Token does not exist");
        return _owners[tokenId];
    }
}
