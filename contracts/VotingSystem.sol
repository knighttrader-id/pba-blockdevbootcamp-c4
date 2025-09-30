// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title Decentralized Voting System
/// @notice Simple voting contract: add candidates, one-vote-per-address, count votes, declare winner
contract DecentralizedVoting {
    address public owner;

    struct Candidate {
        uint256 id;
        string name;
        uint256 voteCount;
    }

    // Candidate storage
    mapping(uint256 => Candidate) public candidates;
    uint256[] public candidateIds;
    uint256 public candidateCounter; // incremental id generator

    // Track who already voted
    mapping(address => bool) public hasVoted;

    // Winner info (set by declareWinner)
    uint256 public winnerId;
    string public winnerName;
    uint256 public winnerVoteCount;
    bool public winnerDeclared;

    // Events
    event CandidateAdded(uint256 indexed id, string name);
    event Voted(address indexed voter, uint256 indexed candidateId);
    event WinnerDeclared(uint256 indexed id, string name, uint256 voteCount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        candidateCounter = 0;
    }

    /// @notice Add a new candidate (owner only)
    /// @param _name Name of the candidate
    function addCandidate(string calldata _name) external onlyOwner {
        require(bytes(_name).length > 0, "Name required");
        candidateCounter += 1;
        uint256 id = candidateCounter;

        candidates[id] = Candidate({
            id: id,
            name: _name,
            voteCount: 0
        });

        candidateIds.push(id);

        emit CandidateAdded(id, _name);
    }

    /// @notice Cast a vote for a candidate by id
    /// @param _candidateId The id of the candidate to vote for
    function vote(uint256 _candidateId) external {
        require(!hasVoted[msg.sender], "Already voted");
        require(_candidateId > 0 && _candidateId <= candidateCounter, "Invalid candidate");

        candidates[_candidateId].voteCount += 1;
        hasVoted[msg.sender] = true;

        emit Voted(msg.sender, _candidateId);
    }

    /// @notice Return the total number of votes for a candidate
    /// @param _candidateId candidate id
    /// @return voteCount number of votes
    function getVotes(uint256 _candidateId) external view returns (uint256 voteCount) {
        require(_candidateId > 0 && _candidateId <= candidateCounter, "Invalid candidate");
        voteCount = candidates[_candidateId].voteCount;
    }

    /// @notice Declare winner by scanning all candidates and storing the winner
    /// @dev This loops through candidateIds to find the highest voteCount. Owner only.
    function declareWinner() external onlyOwner {
        require(candidateIds.length > 0, "No candidates");
        uint256 topId = candidateIds[0];
        uint256 topVotes = candidates[topId].voteCount;

        for (uint256 i = 1; i < candidateIds.length; i++) {
            uint256 cid = candidateIds[i];
            uint256 v = candidates[cid].voteCount;
            if (v > topVotes) {
                topVotes = v;
                topId = cid;
            }
        }

        winnerId = topId;
        winnerName = candidates[topId].name;
        winnerVoteCount = topVotes;
        winnerDeclared = true;

        emit WinnerDeclared(winnerId, winnerName, winnerVoteCount);
    }

    /// @notice Utility: number of candidates
    function totalCandidates() external view returns (uint256) {
        return candidateIds.length;
    }

    /// @notice Get candidate IDs array (read-only)
    function getCandidateIds() external view returns (uint256[] memory) {
        return candidateIds;
    }

    /// @notice Get candidate details by id
    function getCandidate(uint256 _candidateId) external view returns (uint256 id, string memory name, uint256 votes) {
        require(_candidateId > 0 && _candidateId <= candidateCounter, "Invalid candidate");
        Candidate storage c = candidates[_candidateId];
        return (c.id, c.name, c.voteCount);
    }
}
