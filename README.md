# MedicalRecordLedger

MedicalRecordLedger is a blockchain-based solution built on the Stacks blockchain that enables secure and private tracking of medical records while maintaining data integrity and patient privacy.

## Features

- **Record Registration**: Healthcare providers can register medical records with detailed treatment information
- **Privacy-Preserving**: Patient identifiers are stored securely with controlled access
- **Third-party Validation**: Independent validators can verify medical record information
- **Immutable Records**: Blockchain-based records ensure data integrity and audit trails

## Smart Contract Functions

### Administration
- `add-validator`: Register authorized validators who can verify medical record information

### Provider Functions
- `register-record`: Add a new medical record with treatment details and facility information
- `get-provider-records`: View all records registered by a specific healthcare provider

### Validation
- `validate-record`: Authorized validators can validate medical record information
- `is-validator`: Check if an address is an authorized validator

### Data Retrieval
- `get-record`: View complete details about a specific medical record

## Getting Started

1. Clone this repository
2. Install [Clarinet](https://github.com/hirosystems/clarinet) for local development
3. Run `clarinet check` to verify the contract
4. Deploy using Clarinet or the Stacks CLI

## For Healthcare Providers

Providers can register medical records by providing:
- Patient ID (anonymized)
- Treatment details
- Treatment date
- Facility location

## For Validators

Authorized validators can review and validate medical records, ensuring accuracy and compliance with healthcare standards.