;; SPDX-License-Identifier: MIT
;; Token Vesting Contract

;; Error codes
(define-constant err-already-initialized (err u100))
(define-constant err-invalid-duration (err u101))
(define-constant err-invalid-amount (err u102))
(define-constant err-not-initialized (err u103))
(define-constant err-not-beneficiary (err u104))
(define-constant err-calculation (err u105))
(define-constant err-no-tokens-to-release (err u106))
(define-constant err-unwrap-time (err u107))
(define-constant err-arithmetic-underflow (err u108))
(define-constant err-arithmetic-overflow (err u109))
(define-constant err-unauthorized (err u110))
(define-constant err-revoke-failed (err u111))


(define-data-var beneficiary (optional principal) none)
(define-data-var total-tokens uint u0)
(define-data-var tokens-released uint u0)
(define-data-var start-time uint u0)
(define-data-var vesting-duration uint u0)
(define-data-var revoked bool false)

(define-read-only (get-beneficiary)
    (ok (var-get beneficiary))
)

(define-read-only (get-total-tokens)
    (ok (var-get total-tokens))
)

(define-read-only (get-tokens-released)
    (ok (var-get tokens-released))
)

(define-read-only (get-vesting-schedule)
    (ok { 
        start-time: (var-get start-time), 
        vesting-duration: (var-get vesting-duration) 
    })
)

(define-read-only (get-revoked)
  (ok (var-get revoked))
)

(define-private (get-current-time)
    (ok stacks-block-height)
)

(define-private (calculate-vested-tokens)
    (let ((current-time (unwrap! (get-current-time) err-unwrap-time))
          (start (var-get start-time))
          (duration (var-get vesting-duration))
          (total (var-get total-tokens)))
        (asserts! (>= current-time start) err-calculation)
        (let ((elapsed-time (- current-time start)))
            (ok (if (>= elapsed-time duration)
                total
                (/ (* total elapsed-time) duration))))))

(define-public (initialize-vesting (recipient principal) (amount uint) (start uint) (duration uint))
    (begin
        (asserts! (is-eq (var-get beneficiary) none) err-already-initialized)
        (asserts! (> duration u0) err-invalid-duration)
        (asserts! (> amount u0) err-invalid-amount)
        (asserts! (>= start stacks-block-height) err-invalid-duration)
        (asserts! (is-some (some recipient)) err-invalid-duration)
        (var-set beneficiary (some recipient))
        (var-set total-tokens amount)
        (var-set start-time start)
        (var-set vesting-duration duration)
        (ok true)
    )
)

(define-public (release-tokens)
    (let ((recipient (unwrap! (var-get beneficiary) err-not-initialized)))
        (asserts! (is-eq tx-sender recipient) err-not-beneficiary)
        (asserts! (not (var-get revoked)) err-revoke-failed)
        (let ((vested-tokens (unwrap! (calculate-vested-tokens) err-calculation))
              (released-tokens (var-get tokens-released)))
            (asserts! (> vested-tokens released-tokens) err-no-tokens-to-release)
            (let ((amount-to-release (- vested-tokens released-tokens)))
                (begin
                    (var-set tokens-released vested-tokens)
                    (ok amount-to-release)
                )
            )
        )
    )
)

;; New functionalities
(define-public (revoke-vesting)
  (begin
    (asserts! (is-eq tx-sender (unwrap! (var-get beneficiary) err-not-beneficiary)) err-unauthorized)
    (var-set revoked true)
    (ok true)
  )
)

(define-public (update-beneficiary (new-beneficiary principal))
  (begin
    (asserts! (is-eq tx-sender (unwrap! (var-get beneficiary) err-not-beneficiary)) err-unauthorized)
    (asserts! (is-some (some new-beneficiary)) err-invalid-duration)
    (var-set beneficiary (some new-beneficiary))
    (ok true)
  )
)
