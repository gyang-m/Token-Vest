# Token Vesting Contract

This Clarity smart contract implements a token vesting schedule for a designated beneficiary. It allows for a specified amount of tokens to be locked up and gradually released to the beneficiary over a defined period.

## Overview

The contract holds a total amount of tokens and releases them linearly over a vesting duration. The beneficiary can claim their vested tokens at any time after the vesting start time.

## Public Functions

* **`initialize-vesting (recipient principal) (amount uint) (start uint) (duration uint)`:** Initializes the vesting schedule. This function can only be called once.
    * `recipient`: The principal of the beneficiary.
    * `amount`: The total number of tokens to be vested.
    * `start`: The block height at which the vesting begins.
    * `duration`: The duration of the vesting period in block heights.
* **`release-tokens`:** Allows the beneficiary to claim their vested tokens. The sender of the transaction must be the beneficiary.

## Read-only Functions

* **`get-beneficiary`:** Returns the principal of the beneficiary.
* **`get-total-tokens`:** Returns the total number of tokens to be vested.
* **`get-tokens-released`:** Returns the number of tokens already released.
* **`get-vesting-schedule`:** Returns the start time and vesting duration.

## Error Codes

* `err-already-initialized (u100)`: Thrown if the contract is already initialized.
* `err-invalid-duration (u101)`: Thrown if the vesting duration is invalid (zero or less).
* `err-invalid-amount (u102)`: Thrown if the token amount is invalid (zero or less).
* `err-not-initialized (u103)`: Thrown if the contract is not initialized.
* `err-not-beneficiary (u104)`: Thrown if the sender is not the beneficiary.
* `err-calculation (u105)`: Thrown if there's an error during vested token calculation.
* `err-no-tokens-to-release (u106)`: Thrown if there are no tokens to release.
* `err-unwrap-time (u107)`: Thrown if there's an issue unwrapping the current time.
* `err-arithmetic-underflow (u108)`: Thrown if an arithmetic underflow occurs.
* `err-arithmetic-overflow (u109)`: Thrown if an arithmetic overflow occurs.


## Deployment

```bash
clarinet contract deploy token-vesting
