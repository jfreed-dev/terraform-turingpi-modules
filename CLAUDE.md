# Claude Code Context - terraform-turingpi-modules

Project-specific knowledge for Claude Code when working on this repository.

## Repository Overview

Terraform modules for Turing Pi 2.5 cluster provisioning with Talos or K3s on Armbian.

## Key Learnings

### BMC API Node Numbering

The BMC flash API uses **0-indexed** node IDs (0-3), but the internal process names show 1-indexed:
- `node=0` → "Node 1 os install service" (slot 1)
- `node=1` → "Node 2 os install service" (slot 2)
- `node=2` → "Node 3 os install service" (slot 3)
- `node=3` → "Node 4 os install service" (slot 4)

**Note:** `node=4` returns "Parameter `node` is out of range 0..3"

### BMC Flash API

```bash
# Start flash (returns handle)
curl -sk -u USER:PASS "https://BMC_IP/api/bmc?opt=set&type=flash&node=N&file=URL"

# Check progress (bytes_written exceeds size during decompression)
curl -sk -u USER:PASS "https://BMC_IP/api/bmc?opt=get&type=flash"
# Returns: {"Transferring":{"id":HANDLE,"process_name":"...","size":N,"bytes_written":N}}
# Or when done: {"Done":[{"secs":N,"nanos":N},SIZE]}

# Power control
curl -sk -u USER:PASS "https://BMC_IP/api/bmc?opt=set&type=power&node1=1&node2=1&node3=1&node4=1"
curl -sk -u USER:PASS "https://BMC_IP/api/bmc?opt=get&type=power"
```

### Armbian First Boot

- Default credentials: `root` / `1234`
- Autoconfig file: `/boot/armbian_first_run.txt`
- SSH keys must be added manually or via autoconfig script
- Nodes power off after flash completes - must power on manually

### K3s Deployment on Armbian

Prerequisites for Longhorn:
```bash
apt-get install -y open-iscsi nfs-common
systemctl enable iscsid && systemctl start iscsid
```

K3s install with disabled built-ins:
```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="v1.31.4+k3s1" sh -s - server \
    --disable=traefik \
    --disable=servicelb \
    --write-kubeconfig-mode=644
```

Worker join:
```bash
curl -sfL https://get.k3s.io | K3S_URL="https://CP_IP:6443" K3S_TOKEN="TOKEN" sh -s - agent
```

### Bash Script Compatibility

With `set -e`, these patterns cause script exit:
- `((VAR++))` when VAR=0 returns exit code 1
- `[[ condition ]] && command` returns non-zero when condition is false

Use instead:
- `VAR=$((VAR + 1))`
- `if [[ condition ]]; then command; fi`

### Secrets File Location

User stores credentials at `~/.secrets/turning-pi-cluster-bmc`:
```
ip: 10.10.88.70
username: root
password: PASSWORD
```

SSH key at `~/.secrets/turningpi-cluster`

## Cluster Configuration

| Node | Hostname | IP | Role |
|------|----------|-----|------|
| 1 | turing-cp1 | 10.10.88.73 | Control Plane |
| 2 | turing-w1 | 10.10.88.74 | Worker |
| 3 | turing-w2 | 10.10.88.75 | Worker |
| 4 | turing-w3 | 10.10.88.76 | Worker |

- BMC IP: 10.10.88.70
- MetalLB Pool: 10.10.88.80-89
- Kubeconfig: `/tmp/k3s-kubeconfig.yaml`

## Helper Scripts

| Script | Purpose |
|--------|---------|
| `scripts/cluster-preflight.sh` | Pre-deployment validation |
| `scripts/talos-wipe.sh` | Wipe Talos cluster (NVMe + eMMC) |
| `scripts/k3s-wipe.sh` | Wipe K3s cluster (NVMe + eMMC) |
| `scripts/find-armbian-image.sh` | Find images, generate autoconfig |

## Related Repository

- Provider: `/home/jon/Repos/terraform-provider-turingpi`
