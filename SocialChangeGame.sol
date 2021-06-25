// SPDX-License-Identifier: GPL-3.0

/*
100 ether to enter;
require 1000 participants
when hit 1000 participants sort 3 winners randonly
1st place 20% = 20,000 ONEs
2nd place 10% = 10,000 ONEs
3rd place 5% = 5,000 ONEs
DAO fund 65% = 65,000 ONEs
*/

pragma solidity >=0.1.1 <0.8.6;

contract SocialChangeGame {
    // the deployer
    address public owner;
    // dao fund
    address dao;
    // actual event number
    uint private _event;
    // mapping totals in event
    mapping(uint => uint) _totals;
    // mapping for winners numbers
    mapping(uint => uint[3]) winners;
    // mapping for participants
    mapping(uint => mapping(uint => address)) participants;
    // mapping for claimed prizes
    mapping(address => mapping(uint => bool)) claimed;
    // mapping for joineds in events
    mapping(address => mapping(uint => bool)) joined;
    
    event Winner(uint _event, address _winner, uint _position);
    
    constructor(address _dao) {
        _event = 1;
        owner = msg.sender;
        dao = _dao;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function sort() public onlyOwner{
        require(_totals[_event] == 999, "few participants");
        // sort 3 winners
        for(uint i = 0; i < 3; i++){
            // prnd - sorted a number from 0 to 999
            winners[_event][i] = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, i))) % 1000;
            // emit winer
            emit Winner(_event, participants[_event][winners[_event][i]], i);
        }
        // transfer 65% for dao
        _transfer(dao);
        // update _event
        _event = _event + 1;
    }
    
    function claim(uint event_) public {
        if(claimed[msg.sender][event_] == true){
            // revert if already claimed
            revert("already claimed");
        }
        for(uint i = 0; i < winners[event_].length; i++){
            // search for address in sort numbers
            if(participants[event_][winners[event_][i]] == msg.sender){
                // if sorted, call internal _withdraw
                _withdraw(msg.sender, i);
            }
        }
        // revert if not for claim
        revert("nothing for claim");
    }
    
    function _withdraw(address _winner, uint _position) internal {
        if(_position == 0){
            // send prize for #1 sorted
            payable(_winner).transfer(20000 ether);
        }
        if(_position == 1){
            // send prize for #2 sorted
            payable(_winner).transfer(10000 ether);
        }
        if(_position == 2){
            // send prize for #3 sorted
            payable(_winner).transfer(5000 ether);
        }
        // unviable double claim
        claimed[msg.sender][_event] = true;
    }
    
    function join() public payable {
        // 100 ether to enter;
        require(msg.value == 100 ether, "should be 100");
        // only one time per event
        require(joined[msg.sender][_event] == false, "only one time");
        // only 1000 participants
        require(_totals[_event] < 999, "hit maximum");
        // add participant in event
        participants[_event][_totals[_event]] = msg.sender;
        // increment the totals
        _totals[_event] = _totals[_event] + 1;
        // set to true joined key
        joined[msg.sender][_event] = true;
    }
    
    function _transfer(address _dao) internal onlyOwner {
        payable(_dao).transfer(65000 ether);
    }
}