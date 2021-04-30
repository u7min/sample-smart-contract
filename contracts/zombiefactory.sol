pragma solidity ^0.4.19; //solidity 버전 표시

import "./ownable.sol";
import "./safemath.sol";

//contract 는 클래스와 비슷한 개념
contract ZombieFactory is Ownable {

  using SafeMath for uint256;

  event NewZombie(uint zombieId, string name, uint dna);

  //아래와 같은 변수를 상태변수라 하고, 블록체인에 기록된다. (데이터베이스에 기록)
  uint dnaDigits = 16;
  uint dnaModulus = 10 ** dnaDigits;
  uint cooldownTime = 1 days;

  struct Zombie {
    string name;
    uint dna;
    uint32 level;
    uint32 readyTime;
    uint16 winCount;
    uint16 lossCount;
  }

  //이것은 동적배열로, 원소를 계속추가할 수 있는 데이터베이스와 같다.
  Zombie[] public zombies;

  mapping (uint => address) public zombieToOwner;
  mapping (address => uint) public ownerZombieCount;

  function _createZombie(string _name, uint _dna) internal {
    uint id = zombies.push(Zombie(_name, _dna, 1, uint32(now + cooldownTime), 0, 0)) - 1;
    zombieToOwner[id] = msg.sender;
    ownerZombieCount[msg.sender]++;
    NewZombie(id, _name, _dna);
  }

  function _generateRandomDna(string _str) private view returns (uint) {
    uint rand = uint(keccak256(_str));
    return rand % dnaModulus;
  }

  function createRandomZombie(string _name) public {
    //require(ownerZombieCount[msg.sender] == 0);
    uint randDna = _generateRandomDna(_name);
    randDna = randDna - randDna % 100;
    _createZombie(_name, randDna);
  }

}
