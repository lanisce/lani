# Helm Chart Publishing Guide

This guide explains how to publish and use the Lani Helm chart from GitHub.

## Overview

The Lani Helm chart is automatically published to GitHub Pages as a Helm chart repository whenever changes are made to the `helm/lani/` directory. This provides a public, versioned repository for easy installation.

## Repository Setup

### 1. Enable GitHub Pages

1. Go to your GitHub repository settings
2. Navigate to "Pages" section
3. Set source to "GitHub Actions"
4. The chart repository will be available at: `https://your-org.github.io/lani/`

### 2. Automatic Publishing

The chart is automatically published via GitHub Actions:

- **On Push**: When changes are pushed to `main` branch affecting `helm/lani/`
- **On Release**: When a new GitHub release is created
- **Manual**: Via workflow dispatch

## Using the Published Chart

### Add the Helm Repository

```bash
# Add the Lani chart repository
helm repo add lani https://your-org.github.io/lani/

# Update repository index
helm repo update

# Search for available charts
helm search repo lani
```

### Install the Chart

```bash
# Install with default values
helm install my-lani lani/lani

# Install with custom values file
helm install my-lani lani/lani -f my-values.yaml

# Install in specific namespace
helm install my-lani lani/lani --namespace lani-production --create-namespace

# Install specific version
helm install my-lani lani/lani --version 1.0.0
```

### Upgrade the Chart

```bash
# Upgrade to latest version
helm upgrade my-lani lani/lani

# Upgrade with new values
helm upgrade my-lani lani/lani -f updated-values.yaml

# Upgrade to specific version
helm upgrade my-lani lani/lani --version 1.1.0
```

## Chart Versioning

### Semantic Versioning

The chart follows semantic versioning (SemVer):

- **Major** (1.0.0): Breaking changes to chart API or default behavior
- **Minor** (1.1.0): New features, backward compatible
- **Patch** (1.0.1): Bug fixes, backward compatible

### Version Management

1. **Chart.yaml**: Update the `version` field for chart changes
2. **appVersion**: Update for new application releases
3. **Git Tags**: Create GitHub releases for major versions

Example `Chart.yaml`:
```yaml
apiVersion: v2
name: lani
version: 1.2.0      # Chart version
appVersion: "1.2.0" # Application version
```

## Publishing Workflow

### Automatic Publishing

The GitHub Actions workflow automatically:

1. **Lints** the chart for syntax errors
2. **Tests** template rendering with various configurations
3. **Packages** the chart into a `.tgz` file
4. **Generates** repository index (`index.yaml`)
5. **Publishes** to GitHub Pages
6. **Attaches** chart package to GitHub releases

### Manual Publishing

To manually trigger publishing:

```bash
# Via GitHub CLI
gh workflow run helm-release.yml

# Via GitHub web interface
# Go to Actions → Release Helm Chart → Run workflow
```

## Chart Repository Structure

The published repository contains:

```
https://your-org.github.io/lani/
├── index.yaml           # Repository index
├── lani-1.0.0.tgz      # Chart package v1.0.0
├── lani-1.1.0.tgz      # Chart package v1.1.0
└── lani-1.2.0.tgz      # Chart package v1.2.0
```

## Development Workflow

### Making Chart Changes

1. **Clone** the repository
2. **Modify** chart files in `helm/lani/`
3. **Test** locally:
   ```bash
   helm lint helm/lani/
   helm template test helm/lani/ --debug
   ```
4. **Update** version in `Chart.yaml`
5. **Commit** and push changes
6. **Create** GitHub release for major versions

### Local Testing

```bash
# Install from local directory
helm install test-lani ./helm/lani/

# Test with different configurations
helm install test-lani ./helm/lani/ \
  --set postgresql.type=external \
  --set postgresql.external.host=localhost

# Dry run to see generated manifests
helm install test-lani ./helm/lani/ --dry-run --debug
```

## Chart Validation

### Automated Checks

The CI pipeline validates:

- **Syntax**: YAML and template syntax
- **Schema**: Required fields and structure
- **Security**: No hardcoded secrets or privileged containers
- **Dependencies**: Chart dependency resolution
- **Templates**: Rendering with various configurations

### Manual Validation

```bash
# Lint chart
helm lint helm/lani/

# Validate templates
helm template lani helm/lani/ --validate

# Check dependencies
cd helm/lani/
helm dependency update
helm dependency list
```

## Distribution Options

### GitHub Pages (Current)

- **Pros**: Free, automatic, integrated with GitHub
- **Cons**: Public only, GitHub dependency

### OCI Registry (Alternative)

```bash
# Package and push to OCI registry
helm package helm/lani/
helm push lani-1.0.0.tgz oci://ghcr.io/your-org/charts

# Install from OCI
helm install my-lani oci://ghcr.io/your-org/charts/lani --version 1.0.0
```

### Artifact Hub

Submit to [Artifact Hub](https://artifacthub.io/) for public discovery:

1. Create `artifacthub-repo.yml`:
   ```yaml
   repositoryID: your-repo-id
   owners:
     - name: Your Name
       email: your-email@domain.com
   ```
2. Add repository to Artifact Hub
3. Charts will be automatically indexed

## Troubleshooting

### Common Issues

1. **Chart Not Found**
   ```bash
   # Update repository cache
   helm repo update
   
   # Check repository status
   helm repo list
   ```

2. **Version Conflicts**
   ```bash
   # List available versions
   helm search repo lani --versions
   
   # Force upgrade
   helm upgrade my-lani lani/lani --force
   ```

3. **Template Errors**
   ```bash
   # Debug template rendering
   helm template my-lani lani/lani --debug
   
   # Validate against cluster
   helm template my-lani lani/lani --validate
   ```

### Publishing Issues

1. **GitHub Actions Failure**
   - Check workflow logs in GitHub Actions
   - Verify Chart.yaml syntax
   - Ensure all dependencies are available

2. **Pages Not Updating**
   - Check GitHub Pages settings
   - Verify workflow permissions
   - Clear browser cache

## Security Considerations

### Chart Security

- **No Secrets**: Never include secrets in chart templates
- **Non-Root**: All containers run as non-root users
- **Network Policies**: Enable network isolation
- **RBAC**: Minimal required permissions

### Repository Security

- **Branch Protection**: Protect main branch
- **Review Required**: Require PR reviews for chart changes
- **Signed Commits**: Enable commit signing
- **Dependency Scanning**: Monitor chart dependencies

## Best Practices

### Chart Development

1. **Follow Conventions**: Use Helm best practices
2. **Document Changes**: Update CHANGELOG.md
3. **Test Thoroughly**: Test with various configurations
4. **Version Properly**: Follow semantic versioning
5. **Secure by Default**: Enable security features by default

### Repository Management

1. **Regular Updates**: Keep dependencies updated
2. **Monitor Usage**: Track chart downloads and usage
3. **Community Feedback**: Respond to issues and PRs
4. **Documentation**: Keep documentation current

## Support and Community

- **Issues**: [GitHub Issues](https://github.com/your-org/lani/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-org/lani/discussions)
- **Documentation**: [Full Documentation](https://github.com/your-org/lani/tree/main/docs)
- **Chart Repository**: https://your-org.github.io/lani/
