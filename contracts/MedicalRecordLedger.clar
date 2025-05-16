;; MedicalRecordLedger - Secure medical record tracking system
(define-map records uint {
  provider: principal,
  patient-id: (string-utf8 64),
  treatment-details: (string-utf8 256),
  treatment-date: uint,
  facility-location: (string-utf8 64),
  validated: bool
})
(define-map provider-records principal (list 100 uint))
(define-map validators principal bool)
(define-data-var record-id-sequence uint u0)
;; Error codes
(define-constant err-not-provider (err u100))
(define-constant err-not-validator (err u101))
(define-constant err-record-not-found (err u102))
(define-constant err-not-authorized (err u403))
(define-constant err-too-many-records (err u104))
(define-constant err-invalid-principal (err u105))
(define-constant err-invalid-patient-id (err u106))
(define-constant err-invalid-treatment (err u107))
(define-constant err-invalid-date (err u108))
(define-constant err-invalid-location (err u109))
(define-constant err-invalid-record-id (err u110))
;; Contract owner for admin functions
(define-constant contract-owner tx-sender)
;; Add a validator
(define-public (add-validator (validator principal))
  (begin
    ;; Check if sender is contract owner
    (asserts! (is-eq tx-sender contract-owner) err-not-authorized)
    
    ;; Validate validator principal
    (asserts! (not (is-eq validator 'SP000000000000000000002Q6VF78)) err-invalid-principal)
    
    ;; Add validator to map
    (ok (map-set validators validator true))
  )
)
;; Register a new medical record
(define-public (register-record 
  (patient-id (string-utf8 64)) 
  (treatment-details (string-utf8 256)) 
  (treatment-date uint) 
  (facility-location (string-utf8 64)))
  (let
    ((record-id (var-get record-id-sequence))
     (provider tx-sender)
     (provider-current-records (default-to (list) (map-get? provider-records provider))))
    
    ;; Validate inputs
    (asserts! (> (len patient-id) u0) err-invalid-patient-id)
    (asserts! (> (len treatment-details) u0) err-invalid-treatment)
    (asserts! (> treatment-date u0) err-invalid-date)
    (asserts! (> (len facility-location) u0) err-invalid-location)
    
    ;; Check if provider has reached record limit
    (asserts! (< (len provider-current-records) u100) err-too-many-records)
    
    ;; Store the record data
    (map-set records record-id {
      provider: provider,
      patient-id: patient-id,
      treatment-details: treatment-details,
      treatment-date: treatment-date,
      facility-location: facility-location,
      validated: false
    })
    
    ;; Create a new list with the record ID
    (let 
      ((new-record-list (unwrap-panic (as-max-len? (concat (list record-id) provider-current-records) u100))))
      ;; Update provider's record list
      (map-set provider-records provider new-record-list)
    )
    
    ;; Increment the record ID counter
    (var-set record-id-sequence (+ record-id u1))
    
    (ok record-id)))
;; Validate a medical record
(define-public (validate-record (record-id uint))
  (begin
    ;; Validate record ID
    (asserts! (< record-id (var-get record-id-sequence)) err-invalid-record-id)
    
    (let
      ((record (unwrap! (map-get? records record-id) err-record-not-found)))
      
      ;; Check if sender is a validator
      (asserts! (default-to false (map-get? validators tx-sender)) err-not-validator)
      
      ;; Update record validation status
      (ok (map-set records record-id (merge record {validated: true})))
    )
  )
)
;; Get record details
(define-read-only (get-record (record-id uint))
  (map-get? records record-id))
;; Get provider's records
(define-read-only (get-provider-records (provider principal))
  (default-to (list) (map-get? provider-records provider)))
;; Check if principal is a validator
(define-read-only (is-validator (address principal))
  (default-to false (map-get? validators address)))