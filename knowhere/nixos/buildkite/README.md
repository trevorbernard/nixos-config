# Knowhere Buildkite Agent Setup

This directory contains the Nix configuration for a Buildkite agent configured for the knowhere build server.

## Files

- `buildkite.nix` - Main Nix configuration for the Buildkite agent and `bk` user
- `deploy` - Deployment script for setting up the agent with secure token management

## Setup Process

### 1. Get Buildkite Agent Token

1. Go to your knowhere Buildkite organization settings
2. Navigate to "Agents" → "Agent Tokens"
3. Create a new agent token or copy an existing one
4. The token format looks like: `abc123def456...`

### 2. Configure Target Server

Edit the `deploy` script and replace `YOUR_SERVER_IP` with your actual server IP:

```bash
TARGET='root@YOUR_ACTUAL_SERVER_IP'
```

### 3. Deploy the Agent

Run the deployment with your Buildkite token:

```bash
BUILDKITE_AGENT_TOKEN=your_token_here ./deploy
```

**Note**: The deployment script references `config.nix` but this file doesn't exist in this directory. You'll need to either create a `config.nix` file that imports `buildkite.nix`, or modify the deploy script to use the appropriate NixOS configuration for your system.

## Security Details

### Token Storage
- Token is stored securely at `/run/keys/buildkite-agent-token`
- File permissions: `0400` (read-only for owner)
- File ownership: `bk:keys`

### User Setup
- Creates `bk` user with home directory at `/home/bk`
- User is member of `docker` and `keys` groups
- Agent runs under this dedicated user account

### Agent Configuration
- **Name**: `knowhere-agent-%spawn` (spawns 2 agents)
- **Build Path**: `/home/bk/builds`
- **Tags**: `production=false,nix=true,docker=true,os-kernel=linux,os-family=nixos,os-variant=nixos,xwindows=true`

## Alternative Token Setup Methods

### Option A: Environment Variable (Recommended)
```bash
export BUILDKITE_AGENT_TOKEN=your_token_here
./deploy
```

### Option B: Manual File Creation
```bash
# On the target server as root:
mkdir -p /run/keys
echo "your_token_here" > /run/keys/buildkite-agent-token
chown bk:keys /run/keys/buildkite-agent-token
chmod 0400 /run/keys/buildkite-agent-token
```

### Option C: Advanced Secret Management
For production environments, consider using:
- `sops-nix` for encrypted secrets in Git
- `agenix` for age-encrypted secrets
- Hardware security modules (HSM) for enterprise setups

## Troubleshooting

### Check Agent Status
```bash
systemctl status buildkite-agent
journalctl -u buildkite-agent -f
```

### Verify Token Access
```bash
sudo -u bk cat /run/keys/buildkite-agent-token
```

### Check Agent Configuration
```bash
sudo -u bk cat /home/bk/buildkite-agent.cfg
```

### View Agent Logs
```bash
journalctl -u buildkite-agent -f --no-pager
```
