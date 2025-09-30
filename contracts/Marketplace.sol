// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Decentralized Marketplace
/// @notice Simple marketplace where users can list items, buy items with ETH, and sellers withdraw proceeds.
contract DecentralizedMarketplace {
    address public owner;

    struct Item {
        uint256 id;
        string name;
        uint256 price; // in wei
        address seller;
        bool sold;
    }

    // Storage
    mapping(uint256 => Item) public items;
    uint256[] public itemIds;
    uint256 public itemCounter;

    // Track ownership after purchase (buyer address)
    mapping(uint256 => address) public itemOwner;

    // Seller proceeds stored until withdraw (pull pattern)
    mapping(address => uint256) public proceeds;

    // Simple reentrancy guard
    bool private locked;

    // Events
    event ItemListed(uint256 indexed id, string name, uint256 price, address indexed seller);
    event ItemPurchased(uint256 indexed id, address indexed buyer, address indexed seller, uint256 price);
    event Withdrawn(address indexed seller, uint256 amount);

    modifier noReentrant() {
        require(!locked, "Reentrant call");
        locked = true;
        _;
        locked = false;
    }

    modifier validPrice(uint256 _price) {
        require(_price > 0, "Price must be > 0");
        _;
    }

    constructor() {
        owner = msg.sender;
        itemCounter = 0;
    }

    /// @notice List a new item for sale
    /// @param _name Name/title of the item
    /// @param _price Price in wei (must be > 0)
    function listItem(string calldata _name, uint256 _price) external validPrice(_price) {
        require(bytes(_name).length > 0, "Name required");

        itemCounter += 1;
        uint256 id = itemCounter;

        items[id] = Item({
            id: id,
            name: _name,
            price: _price,
            seller: msg.sender,
            sold: false
        });

        itemIds.push(id);

        emit ItemListed(id, _name, _price, msg.sender);
    }

    /// @notice Purchase a listed item by sending exactly the price in msg.value
    /// @param _id Item id to purchase
    function purchaseItem(uint256 _id) external payable noReentrant {
        Item storage it = items[_id];
        require(it.id != 0, "Item does not exist");
        require(!it.sold, "Item already sold");
        require(msg.sender != it.seller, "Seller cannot buy their own item");
        require(msg.value == it.price, "Incorrect ETH amount");

        // Mark sold and assign ownership
        it.sold = true;
        itemOwner[_id] = msg.sender;

        // Credit seller proceeds (pull pattern)
        proceeds[it.seller] += msg.value;

        emit ItemPurchased(_id, msg.sender, it.seller, it.price);
    }

    /// @notice Seller withdraws accumulated proceeds
    function withdrawProceeds() external noReentrant {
        uint256 amount = proceeds[msg.sender];
        require(amount > 0, "No proceeds to withdraw");

        // Zero-out before transfer to prevent reentrancy issues
        proceeds[msg.sender] = 0;

        (bool sent, ) = payable(msg.sender).call{value: amount}("");
        require(sent, "Withdraw failed");

        emit Withdrawn(msg.sender, amount);
    }

    /// @notice Get item details
    function getItem(uint256 _id) external view returns (
        uint256 id,
        string memory name,
        uint256 price,
        address seller,
        bool sold,
        address currentOwner
    ) {
        Item storage it = items[_id];
        require(it.id != 0, "Item does not exist");
        id = it.id;
        name = it.name;
        price = it.price;
        seller = it.seller;
        sold = it.sold;
        currentOwner = itemOwner[_id];
    }

    /// @notice Return total number of listed items
    function totalItems() external view returns (uint256) {
        return itemIds.length;
    }

    /// @notice Return all item IDs (useful for front-end)
    function getItemIds() external view returns (uint256[] memory) {
        return itemIds;
    }

    /// @notice Get proceeds for a seller
    function getProceeds(address _seller) external view returns (uint256) {
        return proceeds[_seller];
    }
}
