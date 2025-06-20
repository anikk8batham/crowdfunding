// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Crowdfunding {
    address public owner;
    uint public campaignCount = 0;

    struct Campaign {
        address creator;
        string title;
        string description;
        uint goal;
        uint raised;
        uint deadline;
        bool isOpen;
    }

    mapping(uint => Campaign) public campaigns;
    mapping(uint => mapping(address => uint)) public contributions;

    event CampaignCreated(uint id, address creator, string title, uint goal);
    event ContributionReceived(uint id, address contributor, uint amount);
    event CampaignClosed(uint id, bool successful);

    constructor() {
        owner = msg.sender;
    }

    function createCampaign(string memory _title, string memory _description, uint _goal, uint _durationInDays) public {
        campaignCount++;
        campaigns[campaignCount] = Campaign({
            creator: msg.sender,
            title: _title,
            description: _description,
            goal: _goal,
            raised: 0,
            deadline: block.timestamp + (_durationInDays * 1 days),
            isOpen: true
        });
        emit CampaignCreated(campaignCount, msg.sender, _title, _goal);
    }

    function contribute(uint _id) public payable {
        Campaign storage c = campaigns[_id];
        require(c.isOpen, "Campaign is closed");
        require(block.timestamp < c.deadline, "Campaign deadline passed");
        require(msg.value > 0, "Contribution must be greater than 0");

        c.raised += msg.value;
        contributions[_id][msg.sender] += msg.value;
        emit ContributionReceived(_id, msg.sender, msg.value);
    }

    function closeCampaign(uint _id) public {
        Campaign storage c = campaigns[_id];
        require(msg.sender == c.creator, "Only creator can close");
        require(c.isOpen, "Already closed");

        c.isOpen = false;
        if (c.raised >= c.goal) {
            payable(c.creator).transfer(c.raised);
            emit CampaignClosed(_id, true);
        } else {
            emit CampaignClosed(_id, false);
        }
    }

    function getCampaign(uint _id) public view returns (
        address, string memory, string memory, uint, uint, uint, bool
    ) {
        Campaign memory c = campaigns[_id];
        return (
            c.creator,
            c.title,
            c.description,
            c.goal,
            c.raised,
            c.deadline,
            c.isOpen
        );
    }
}
