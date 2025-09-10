# Deployment Guide

## Prerequisites

1. **AWS CLI configured** with OrganizationAdmin role
2. **Terraform** installed (v1.5.0+)
3. **Ansible** installed (v8.0.0+)
4. **Make** available for task automation

## Local Development

### Validation
```bash
make validate
```

### Planning
```bash
make plan
```

### Deployment
```bash
make apply
```

## Production Deployment

### Manual Deployment
```bash
./scripts/deploy.sh production
```

### CI/CD Pipeline
Push to `main` branch triggers automatic deployment via GitHub Actions.

## Drift Detection

Run daily to check for configuration drift:
```bash
./scripts/drift-detection.sh
```

## Environment Management

Configuration files in `environments/`:
- `development.yml` - Lower cost limits for testing
- `production.yml` - Production-ready configuration

## Testing

Run all tests:
```bash
make test
python3 tests/test_ansible_templates.py
```

## Troubleshooting

### Common Issues

1. **Terraform state lock**: Wait or force unlock if needed
2. **AWS credentials**: Ensure correct profile is set
3. **Ansible path**: Verify pipx PATH is configured

### Emergency Procedures

1. **Rollback**: Use `terraform destroy` then redeploy previous version
2. **Manual intervention**: Access AWS console with OrganizationAdmin role
3. **State recovery**: Restore from S3 bucket versioning