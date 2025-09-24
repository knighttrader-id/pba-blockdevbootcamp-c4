// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

/**
 * @title MembershipSystem
 * @dev A simple smart contract to manage members in a system.
 * Uses a mapping from address to bool to track membership status.
 */
contract MembershipSystem {
    /**
     * @dev Mapping to store membership status.
     * members[address] = true  -> The address is a member
     * members[address] = false -> The address is NOT a member
     *
     * We keep this mapping PRIVATE so that other contracts or users
     * cannot directly access it. Instead, we provide the isMember() 
     * function as a controlled way to check membership status.
     */
    mapping(address => bool) private members;

    /**
     * @notice Add a new member to the system
     * @dev 
     * - This function is marked as EXTERNAL because:
     *   1. It is intended to be called from outside the contract (e.g., by a dApp or wallet).
     *   2. `external` is slightly cheaper than `public` when passing arguments.
     * - The function changes contract state (storage), so it cannot be `view` or `pure`.
     *
     * @param _member The address of the new member to add
     */
    function addMember(address _member) external {
        members[_member] = true;
    }

    /**
     * @notice Remove an existing member from the system
     * @dev 
     * - This function is also EXTERNAL for the same reason as addMember.
     * - It modifies the mapping, so it cannot be `view` or `pure`.
     *
     * @param _member The address of the member to remove
     */
    function removeMember(address _member) external {
        members[_member] = false;
    }

    /**
     * @notice Check if an address is a member
     * @dev 
     * - This function is marked as VIEW because:
     *   1. It only *reads* from the blockchain (storage).
     *   2. It does not modify any state, so it costs no gas if called off-chain.
     * - It is EXTERNAL so it can be queried by wallets, dApps, or other contracts.
     * - It cannot be PURE because it reads from storage.
     *
     * @param _member The address to check
     * @return bool True if _member is in the membership system, false otherwise
     */
    function isMember(address _member) external view returns (bool) {
        return members[_member];
    }

    /**
     * Example of a PURE function (not used in this contract):
     * - PURE means it does not read or write to blockchain storage.
     * - Only does calculations with input values.
     */
    function addNumbers(uint256 a, uint256 b) external pure returns (uint256) {
        return a + b; // does not touch state
    }
}
