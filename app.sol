// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";

contract EtherusdGang is ERC20, Pausable, Ownable, ERC20Permit, ERC20Votes {
    constructor() ERC20("Etherusd Gang", "EG") ERC20Permit("Etherusd Gang") {
        superAdmin = msg.sender;
        admins[msg.sender] = true; // Make the super admin an admin by default
        adminAddresses.push(superAdmin);

        // Set the total supply to 1 million tokens (1,000,000 * 10^18)
        _mint(msg.sender, 7_000_000 * 10**18);
    }

    // Super admin address
    address private superAdmin;
    // Array to store admin addresses
    address[] public adminAddresses;
    // Mapping to keep track of admin addresses
    mapping(address => bool) internal admins;
    // Array to keep track of admin proposals from users
    AdminProposal[] public adminProposals;

    struct AdminProposal {
        address proposedAdmin;
        uint256 supportVotes;
        uint256 opposeVotes;
        bool executed;
    }

    // Modifier to restrict access to the super admin
    modifier onlySuperAdmin() {
        require(
            msg.sender == superAdmin,
            "Only the super admin can perform this action."
        );
        _;
    }

    // Modifier to restrict access to admins (excluding super admin)
    modifier onlyAdmin() {
        require(admins[msg.sender], "Only admins can perform this action.");
        _;
    }

    // Mapping to keep track of whether a user has voted for a specific proposal
    mapping(address => mapping(uint256 => bool)) public hasVoted;

    // Function to remove an admin (only super admin can call this)
    function removeAdmin(address _admin) public onlySuperAdmin {
        require(admins[_admin], "Address is not an admin.");
        admins[_admin] = false;
        // Remove the address from the adminAddresses array
        for (uint256 i = 0; i < adminAddresses.length; i++) {
            if (adminAddresses[i] == _admin) {
                adminAddresses[i] = adminAddresses[adminAddresses.length - 1];
                adminAddresses.pop();
                break;
            }
        }
    }

    // Function to initiate an admin proposal (only admins can call this)
    function initiateAdminProposal(address proposedAdmin) public onlyAdmin {
        // Create a new admin proposal and add it to the array
        adminProposals.push(
            AdminProposal({
                proposedAdmin: proposedAdmin,
                supportVotes: 0,
                opposeVotes: 0,
                executed: false
            })
        );
    }

    function executeAdminProposal(uint256 _proposalId) public onlySuperAdmin {
        require(_proposalId < adminProposals.length, "Invalid proposal ID.");
        require(
            !adminProposals[_proposalId].executed,
            "Proposal has already been executed."
        );

        AdminProposal storage proposal = adminProposals[_proposalId];

        // Check if the proposal has received the majority of support votes
        uint256 totalSupportVotes = proposal.supportVotes;
        uint256 totalOpposeVotes = proposal.opposeVotes;
        require(
            totalSupportVotes > totalOpposeVotes,
            "Not enough support votes for the proposal."
        );

        // Execute the proposal by adding the proposed admin.
        admins[proposal.proposedAdmin] = true;
        adminAddresses.push(proposal.proposedAdmin);

        // Mark the proposal as executed.
        proposal.executed = true;
    }

    function voteForAdminProposal(uint256 _proposalId, bool support) public {
        require(_proposalId < adminProposals.length, "Invalid proposal ID.");
        require(
            !adminProposals[_proposalId].executed,
            "Proposal has already been executed."
        );
        require(
            !hasVoted[msg.sender][_proposalId],
            "You have already voted for this proposal."
        );

        // Mark the user as voted for this proposal
        hasVoted[msg.sender][_proposalId] = true;

        // Update the vote counts based on whether the user supports or opposes
        if (support) {
            adminProposals[_proposalId].supportVotes += 1;
        } else {
            adminProposals[_proposalId].opposeVotes += 1;
        }
    }

    function pause() public onlySuperAdmin {
        _pause();
    }

    function unpause() public onlySuperAdmin {
        _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }

    // The following functions are overrides required by Solidity.

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        require(
            totalSupply() + amount <= 7_000_000 * 10**18,
            "Exceeds total supply limit"
        );
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._burn(account, amount);
    }

    // Function to get the number of upvotes and downvotes for a proposal
    function getVotesForProposal(uint256 proposalId)
        public
        view
        returns (uint256 supportVotes, uint256 opposeVotes)
    {
        require(proposalId < adminProposals.length, "Invalid proposal ID");

        AdminProposal storage proposal = adminProposals[proposalId];
        return (proposal.supportVotes, proposal.opposeVotes);
    }
}
