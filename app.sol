// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract EtherustContract {
    IERC20 public etherUSDToken;
    address public owner;

    // Super admin address
    address private superAdmin;
    // Array to store admin addresses
    address[] public adminAddresses;
    // Mapping to keep track of admin addresses
    mapping(address => bool) internal admins;
    // Array to keep track of admin proposals from users
    AdminProposal[] public adminProposals;

    constructor(address _tokenAddress) {
        etherUSDToken = IERC20(_tokenAddress);
        owner = msg.sender;
        superAdmin = msg.sender;
        admins[msg.sender] = true; // Make the super admin an admin by default
        adminAddresses.push(superAdmin);
    }

    struct AdminProposal {
        address proposedAdmin;
        uint256 supportVotes;
        uint256 opposeVotes;
        bool executed;
    }

    uint8 minTokensRequired = 7;
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

    // Get the user's token balance directly from the token contract
    uint256 userTokenBalance = etherUSDToken.balanceOf(msg.sender);

    // Check if the user has a minimum number of tokens (adjust the value accordingly)
    require(
        userTokenBalance >= minTokensRequired,
        "Insufficient tokens."
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

    // Function to get the balance of a user in EtherUSD tokens
    function getUserBalance(address user) public view returns (uint256) {
        return etherUSDToken.balanceOf(user);
    }

}
