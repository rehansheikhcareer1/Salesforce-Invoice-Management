# Installation Guide

## Prerequisites

- Salesforce Developer Org or Sandbox
- Salesforce CLI installed
- VS Code with Salesforce Extensions

## Setup Steps

### 1. Clone Repository

```bash
git clone https://github.com/rehansheikhcareer1/Salesforce-Invoice-Management.git
cd Salesforce-Invoice-Management
```

### 2. Authorize Your Org

```bash
sf org login web --alias InvoiceOrg
```

### 3. Deploy Metadata

```bash
sf project deploy start --target-org InvoiceOrg
```

### 4. Assign Permission Set (if created)

```bash
sf org assign permset --name Invoice_Manager --target-org InvoiceOrg
```

### 5. Load Sample Data (Optional)

```bash
sf data import tree --plan data/sample-data-plan.json --target-org InvoiceOrg
```

## Post-Installation

1. Navigate to App Launcher → Invoice Management
2. Create your first Client record
3. Generate an Invoice with Line Items
4. Record a Payment
5. Check the Dashboard for analytics

## Troubleshooting

- **Deployment Errors**: Check API version compatibility
- **Permission Issues**: Verify object and field-level security
- **Flow Not Triggering**: Ensure Flow is activated

## Support

For issues or questions, contact via GitHub.
