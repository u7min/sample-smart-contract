pragma solidity ^0.4.19; // solidity 버전 표시

import "./ownable.sol";
import "./safemath.sol";

// contract 는 클래스와 비슷한 개념
// is 는 extends 와 비슷한 컨트랙트 상속의 개념(다중상속 가능)
contract ZombieFactory is Ownable {

  using SafeMath for uint256;

  event NewZombie(uint zombieId, string name, uint dna);

  // 아래와 같은 변수를 상태변수라 하고, 블록체인에 기록된다. (데이터베이스에 기록)
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

  // 이것은 동적배열로, 원소를 계속추가할 수 있는 데이터베이스와 같다.
  Zombie[] public zombies;

  // Key-Value 저장소, Address는 유저의 Account 주소를 담을 수 있다.
  mapping (uint => address) public zombieToOwner;
  mapping (address => uint) public ownerZombieCount;

  function _createZombie(string _name, uint _dna) internal {
    uint id = zombies.push(Zombie(_name, _dna, 1, uint32(now + cooldownTime), 0, 0)) - 1;
    zombieToOwner[id] = msg.sender; // msg.sender는 호출하는 유저의 Account
    ownerZombieCount[msg.sender]++;
    NewZombie(id, _name, _dna);
  }

  function _generateRandomDna(string _str) private view returns (uint) {
    uint rand = uint(keccak256(_str));
    return rand % dnaModulus;
  }

  function createRandomZombie(string _name) public {
    // require(ownerZombieCount[msg.sender] == 0);
    // require구문은 조건이 참이 아닐경우 에러를 발생시키며, 주로 송신자를 체크할때 자주 쓰인다.
    uint randDna = _generateRandomDna(_name);
    randDna = randDna - randDna % 100;
    _createZombie(_name, randDna);
  }

}
