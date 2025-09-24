// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Membership System Upgrade
// This smart contract demonstrates how to use enum, struct, and mapping in Solidity.

contract MembershipSystem {

    // Enum: defines possible membership statuses
    enum MembershipStatus { Basic, Premium, VIP }

    // Struct: groups related member data into one object
    struct Member {
        uint id;                  // Unique ID for each member
        string name;              // Member’s name
        uint balance;             // Example balance, could represent points or credits
        MembershipStatus membershipType; // Membership type (Basic, Premium, VIP)
        bool isActive;            // Whether member is active
    }

    // --- State Variables ---

    // `private`: Makes the mapping accessible only within this contract.
    // Why is this important? It enforces **encapsulation**, a core security principle. By hiding the data,
    // you ensure it can only be modified through controlled functions, preventing unauthorized direct access.
    mapping(address => Member) private members;

    // `internal`: Makes the counter accessible within this contract and by any contracts that inherit from it.
    // Why is this important? It supports **extensibility**. If you build a new contract on top of this one,
    // it can still use and modify the counter, making your code reusable and modular.
    uint internal memberCounter = 1;

    // --- Events ---
    // Events are a gas-efficient way for a contract to broadcast that a specific action has occurred.
    // External applications (like a dApp frontend) can listen for these events to update their state and UI.
    // The `indexed` keyword makes event data searchable, which is critical for performance.
    event MemberAdded(address indexed memberAddress, uint id, string name);
    event MemberNameUpdated(address indexed memberAddress, string newName);
    event MemberRemoved(address indexed memberAddress);


    // --- Functions ---

    /**
     * @dev Adds a new member to the system.
     * @param _memberAddress The wallet address of the new member.
     * @param _name The name of the new member.
     * Why `external`? This function is designed to be called only from outside the contract (by users).
     * `external` is more gas-efficient than `public` for this use case because it doesn't need to copy arguments to memory.
     */
    function addMember(address _memberAddress, string memory _name) external {
        // --- Input Validation (Remarks) ---
        // require(_memberAddress != address(0), "Cannot add member with zero address.");
        // require(members[_memberAddress].id == 0, "Member with this address already exists.");
        // require(bytes(_name).length > 0, "Member name cannot be empty.");

        // --- How This Works: Storage Pointers for Maximum Gas Efficiency ---
        // The line below is a critical optimization pattern in Solidity. It creates a `storage pointer` named `newMember`.
        // It does **not** create a copy of the data in memory.
        //
        // **Why this is gas-efficient:**
        // A `storage pointer` is a direct reference—an alias—to the data's location on the blockchain. When you modify
        // `newMember.id`, you are directly executing a write operation (`SSTORE` opcode) on that specific storage slot.
        // This avoids the costly step of loading the entire struct into memory, modifying it there, and then writing the whole
        // thing back to storage. By operating directly on storage, you minimize operations and save significant gas,
        // which is crucial for keeping transaction costs low for your users.
        Member storage newMember = members[_memberAddress];
        newMember.id = memberCounter;
        newMember.name = _name;
        newMember.balance = 0;
        newMember.membershipType = MembershipStatus.Basic; // Default membership
        newMember.isActive = true;

        emit MemberAdded(_memberAddress, newMember.id, newMember.name);
        memberCounter++;
    }

    /**
     * @dev Updates the name of an existing member.
     * Why `external`? Same reason as addMember: it's only called from outside and is more gas-efficient.
     */
    function updateMemberName(address _memberAddress, string memory _newName) external {
        // --- Input Validation (Remarks) ---
        // require(members[_memberAddress].id != 0, "Member does not exist.");
        // require(bytes(_newName).length > 0, "New name cannot be empty.");

        members[_memberAddress].name = _newName;
        emit MemberNameUpdated(_memberAddress, _newName);
    }

    /**
     * @dev Deactivates a member by setting their isActive flag to false.
     * Why `external`? Again, this is an action initiated by an external user, making `external` the optimal choice.
     */
    function removeMember(address _memberAddress) external {
        // --- Input Validation (Remarks) ---
        // require(members[_memberAddress].id != 0, "Member does not exist.");
        // require(members[_memberAddress].isActive, "Member is already inactive.");

        // This is a "soft delete" - it preserves member data but marks them as inactive.
        members[_memberAddress].isActive = false;

        // --- Hard Delete (Remark) ---
        // For a permanent "hard delete" that clears all data and provides a gas refund, you would use:
        // delete members[_memberAddress];

        emit MemberRemoved(_memberAddress);
    }
    
    // --- Getter Functions ---
    
    /**
     * @dev Checks if an address is registered as an active member.
     * Why `external view`? This function only reads state, so `view` is appropriate and saves gas.
     */
    function isMember(address _memberAddress) external view returns (bool) {
        return members[_memberAddress].id != 0 && members[_memberAddress].isActive;
    }

    /**
     * @dev Retrieves the details of a specific member.
     * @param _memberAddress The address of the member to look up.
     * Why `external view`? Needed to allow external callers to read data from the `private` members mapping without gas cost.
     */
    function getMemberDetails(address _memberAddress) external view returns (uint, string memory, uint, MembershipStatus, bool) {
        Member storage m = members[_memberAddress];
        return (m.id, m.name, m.balance, m.membershipType, m.isActive);
    }

    /**
     * @dev Returns the next available member ID.
     * Why `external view`? Allows anyone to see the current member count without gas cost. Necessary because `memberCounter` is now `internal`.
     */
    function getNextMemberId() external view returns (uint) {
        return memberCounter;
    }
}