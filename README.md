# Token Vesting Contract

This Clarity smart contract implements a token vesting schedule for a designated beneficiary. It allows for a specified amount of tokens to be locked up and gradually released to the beneficiary over a defined period.  It also includes functionality for revoking the vesting schedule and updating the beneficiary.

## Overview

The contract holds a total amount of tokens and releases them linearly over a vesting duration. The beneficiary can claim their vested tokens at any time after the vesting start time.

## How It Works

1. **Initialization:** The `initialize-vesting` function sets up the vesting schedule. It takes the beneficiary's principal, the total number of tokens to vest, the starting block height, and the vesting duration as parameters.  This function can only be called once.

2. **Vesting Calculation:** The `calculate-vested-tokens` private function calculates the number of tokens vested at any given block height. It uses a linear vesting formula:

    ```
    vested_tokens = (total_tokens * elapsed_time) / vesting_duration
    ```

    where `elapsed_time` is the number of blocks since the vesting start time.

3. **Token Release:** The `release-tokens` function allows the beneficiary to claim their vested tokens. It calculates the currently vested tokens and transfers the difference between the vested amount and the previously released amount to the beneficiary.  This function will fail if the vesting schedule has been revoked.

4. **Revoking Vesting:** The `revoke-vesting` function allows the beneficiary to permanently stop the vesting process.  After revocation, no further tokens can be released.

5. **Updating Beneficiary:** The `update-beneficiary` function allows the current beneficiary to change the recipient of the vested tokens.

6. **Data Storage:** The contract stores the beneficiary's principal, total tokens, released tokens, start time, vesting duration, and revocation status in Clarity data variables.

## Public Functions

* **`initialize-vesting (recipient principal) (amount uint) (start uint) (duration uint)`:** Initializes the vesting schedule. This function can only be called once.
    * `recipient`: The principal of the beneficiary.
    * `amount`: The total number of tokens to be vested.
    * `start`: The block height at which the vesting begins.
    * `duration`: The duration of the vesting period in block heights.
* **`release-tokens`:** Allows the beneficiary to claim their vested tokens. The sender of the transaction must be the beneficiary.  Fails if vesting is revoked.
* **`revoke-vesting`:** Allows the beneficiary to revoke the vesting schedule, preventing further token releases.  The sender must be the beneficiary.
* **`update-beneficiary (new-beneficiary principal)`:** Allows the current beneficiary to update the beneficiary to a new principal. The sender must be the current beneficiary.

## Read-only Functions

* **`get-beneficiary`:** Returns the principal of the beneficiary.
* **`get-total-tokens`:** Returns the total number of tokens to be vested.
* **`get-tokens-released`:** Returns the number of tokens already released.
* **`get-vesting-schedule`:** Returns the start time and vesting duration.
* **`get-revoked`:** Returns the revocation status (true if revoked, false otherwise).

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
* `err-unauthorized (u110)`: Thrown if a function is called by an unauthorized user.
* `err-revoke-failed (u111)`: Thrown if `release-tokens` is called after the vesting schedule has been revoked.


## Deployment

```bash
clarinet contract deploy token-vesting
