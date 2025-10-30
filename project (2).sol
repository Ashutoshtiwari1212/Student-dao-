// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title StudentUnionDAO – College Governance with DAO
 * @notice A decentralized governance system for college decision-making.
 * @dev Simple DAO for proposal creation, voting, and execution.
 */
contract StudentUnionDAO {
    struct Proposal {
        uint256 id;
        string description;
        uint256 votesFor;
        uint256 votesAgainst;
        bool executed;
        address proposer;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(address => bool) public members;
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    uint256 public proposalCount;

    event MemberAdded(address member);
    event ProposalCreated(uint256 id, string description, address proposer);
    event Voted(uint256 proposalId, address voter, bool support);
    event ProposalExecuted(uint256 proposalId, bool approved);

    modifier onlyMember() {
        require(members[msg.sender], "Not a DAO member");
        _;
    }

    constructor() {
        members[msg.sender] = true; // Founder becomes first member
    }

    /// @notice Add new member to the DAO
    function addMember(address _member) external onlyMember {
        require(!members[_member], "Already a member");
        members[_member] = true;
        emit MemberAdded(_member);
    }

    /// @notice Create a new proposal
    function createProposal(string calldata _description) external onlyMember {
        proposalCount++;
        proposals[proposalCount] = Proposal({
            id: proposalCount,
            description: _description,
            votesFor: 0,
            votesAgainst: 0,
            executed: false,
            proposer: msg.sender
        });
        emit ProposalCreated(proposalCount, _description, msg.sender);
    }

    /// @notice Vote on a proposal
    function vote(uint256 _proposalId, bool _support) external onlyMember {
        Proposal storage proposal = proposals[_proposalId];
        require(!hasVoted[_proposalId][msg.sender], "Already voted");
        require(!proposal.executed, "Proposal executed");

        hasVoted[_proposalId][msg.sender] = true;

        if (_support) {
            proposal.votesFor++;
        } else {
            proposal.votesAgainst++;
        }

        emit Voted(_proposalId, msg.sender, _support);
    }

    /// @notice Execute a proposal if majority voted for
    function executeProposal(uint256 _proposalId) external onlyMember {
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.executed, "Already executed");

        proposal.executed = true;
        bool approved = proposal.votesFor > proposal.votesAgainst;

        emit ProposalExecuted(_proposalId, approved);
    }
}
