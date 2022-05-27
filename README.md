# Solutions for [Capture the Ether](https://capturetheether.com) game.

## Warmup

1. Deploy a contract
2. Call me
3. Choose a nickname
   > Just deploy and call the contracts, use Remix and Ropsten

## Lotteries

1. [Guess the number](contracts/lotteries/GuessTheNumber.sol)

   > Answer is assigned to the private variable which you can clearly see in the code. If source code is not available you can get value of private variable with [`provider.getStorageAt(<address>, <storage_index>)`](https://docs.ethers.io/v5/api/providers/provider/#Provider-getStorageAt).

2. [Guess the secret number](contracts/lotteries/GuessTheSecretNumber.sol)

   > uint8 max is 256, just bruteforce.

3. [Guess the random number](contracts/lotteries/GuessTheRandomNumber.sol)

   > see #1

4. [Guess the new number](contracts/lotteries/GuessTheNewNumber.sol)

   > Determenistic random, not really random. There is an exploit contract in the source code.

5. [Predict the future](contracts/lotteries/PredictTheFuture.sol)

   > Answer is in `0..9` range due to `% 10`, just bruteforce with the help of exploit contract.

6. [Predict the block hash](contracts/lotteries/PredictTheBlockHash.sol)
   > You can access only 256 last block hashes with `block.blockhash`, so we just need to wait and the answer will be `0x0`. Took around 1.5h on ropsten.

## Math

1. [Token sale](contracts/math/TokenSale.sol)

   > Basic overflow, see exploit contract.

2. [Token whale](contracts/math/TokenWhale.sol)

   > Basic underflow. Error in `_transfer` function, which uses `msg.sender` instead of `from`. Deploy exploit contract, give MAX allowance 2^256-1, and then use `transferFrom` as an exploit contract, which underflows the exploit contract `balance`, then just transfer to tokens to the `msg.sender`. See exploit contract for the implementation.

3. [Retirement fund](contracts/math/RetirementFund.sol)

   > Basic eth balance check error. You can use [Suicide Contract](contracts/utils/Suicide.sol) to increase balance of target contract then just use `collectPenalty` function to sweep the ether.

4. [Mapping](contracts/math/Mapping.sol)

   > This is fancy. We need to overrite isCompleted in slot 0. First expand the map length (which is in slot 1) with `key = 2^256 - 2` then just find the slot to overflow map index with `key = 2^256 - int(keccak(slot 0))` and value `1`.

5. [Donation](contracts/math/Donation.sol)

   > Error when initializing Donation struct, which directly writes to the storage slots, so we can overwrite `owner` in slot 1 by sending `uint(<our address>` as amount. Due to the another bug inside guard function which incorrectly calculates scale, we need less real `msg.value`, i.e. `msg.value = etherAmount / 10^36`.

6. [Fifty years](contracts/math/FiftyYears.sol)

   > Entry point of the exploit is inside the else block of `upsert` function, as (same as above) writes directly to the storage slot 0 and 1. We can use `upsert` function to overwrite head variable at slot 1, first `upsert(1, 2**256-24*60*60)` (fancy timestamp to overflow guard check), second `upsert(2,0)` to reset head variable to 0, and we end up with: `head = 0`. Now we can `withdraw(2)` to sweep the ether (to fix amount problem use [Suicide Contract](contracts/utils/Suicide.sol)).

## Accounts

1. [Fuzzy identity](contracts/accounts/FuzzyIdentity.sol)

   > See exploit contract, to bruteforce contract address use [Profanity vanity address generator for Ethereum](https://github.com/johguse/profanity). Use like this: `./profanity --contract --matching badc0de`, its pretty quick. Grab the pk and deploy exploit contract from generated account. Also you can use `CREATE2` to generate contract address, but first one is easier.

2. [Public Key](contracts/accounts/PublicKey.sol)

   > We can recover uncompressed public key from mined transactions. So we just find tx by the owner on etherscan, get signature and recover public key with `ethers.utils.recoverPublicKey`.

3. [Account Takeover](contracts/accounts/AccountTakeover.sol)

   > This is similar to above, by cheking tx from the owner we get signatures for the transactions, some of them share r (in {r,s,v} signature object), which shouldn't be the same. By doing some fancy math and google, we can recover private key for that address.

## Miscellaneous

1. [Assume ownership](contracts/misc/AssumeOwnership.sol)

   > Lol, I did same mistake in the past, constructor is not really constructor. Thanks gods and Vitalik for fixing this!

2. [Token bank](contracts/misc/TokenBank.sol)

   > Basic reentracy. Deploy the exploit contract, get your tokens from the bank, give an allowance to the exploit contract and execute `exploit()` function.
