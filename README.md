---

## 🚀 Deployment & Silent Launch (Zero-Flash)

By default, launching a PowerShell GUI script or an underlying batch script creates a temporary black console window (`cmd.exe` or `powershell.exe`) flashing across the screen before the WinForms window initialization completes. 

To bypass this legacy limitation and ensure a completely silent application startup, deployment uses a **Shortcut Window-State Hook** workflow.

### 1. File Structure Setup

Place your primary diagnostic payload script and your launcher engine file in the same dedicated deployment directory:

.\Foldername\
├── NetworkSuite.ps1
└── Launch.bat

```
Diagnostic Suite (Main Dashboard)
├── [NETWORK] Tab
│    ├── DNS Inspector          (Queries common records via Resolve-DnsName)
│    ├── Ping Logger            (Real-time live multi-packet polling engine)
│    ├── Port Scanner           (Asynchronous raw socket TCP connect verification)
│    ├── Traceroute Tool        (Custom TTL-increment hop discovery engine)
│    ├── Adapter Info           (Pulls IP, Gateways, DNS, and physical MAC addresses)
│    ├── Netstat Visualizer     (Maps active TCP mappings to parent Process Names)
│    ├── ARP Discovery          (Multi-threaded broadcast sweep & L2 cache mapping)
│    └── WAN & ISP Triage       (External WAN IP, Geolocation, ISP, and backbone metrics)
│
└── [SYSTEM] Tab
├── System Profiler        (Hardware makeup, OS spec, Uptime, User, and BitLocker)
├── Event Log Inspector    (Gathers recent Level 1/2/3 Critical/Error/Warning events)
└── Account Status         (Queries local/ADSI/EntraID active user account properties)
```

### 2. The Launcher Configuration (`Launch.bat`)
Populate your wrapper payload batch script with the following self-elevating architecture. This script handles the initial dynamic check, passes execution off to a hidden background process pipeline, and requests administrative privileges cleanly:

```
@echo off
if "%~1"=="elevated" goto :run
powershell -NoProfile -WindowStyle Hidden -Command "Start-Process '%~f0' -ArgumentList 'elevated' -Verb RunAs"
exit /b

:run
cd /d "%~dp0"
start "" powershell.exe -WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File "NetworkSuite.ps1"
```

Tool Deep Dive & Mechanics
🔍 ARP Discovery & Sweep Engine

    The Mechanics: Querying standard neighbor caches using arp -a or Get-NetNeighbor typically presents stale historical records. To solve this, the ARP Discovery tool broadcasts 254 simultaneous asynchronous network pings across a Class C subnet space using the standard .SendAsync() method from the .NET System.Net.NetworkInformation.Ping namespace.

    The Execution: Using an aggressive 150ms timeout, it quickly wakes up every active node interface on the physical local wire. Even if a target machine's host firewall blocks incoming ICMP echo packets, the target's network interface hardware is bound by TCP/IP stack standards to send an ARP Reply packet back to your station to handle identity resolution.

    The Parser: The tool gives the OS a 2-second buffer to capture back the parallel replies, then targets the live Layer 2 neighbor table cache, gracefully dropping any entries flagged as Unreachable.

    Subnet Flexibility (CIDR Input Parsing): The subnet text field incorporates an integrated Regular Expression (Regex) parser (^([0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3})). This allows agents to natively type or paste unformatted IP ranges or standard CIDR notations (e.g., 192.168.1.0/24, 10.0.0.1/24, or 192.168.1.). The script cleanly isolates the first three octets automatically and drops input validation errors if unparsable strings are supplied.

Understanding Neighbor Cache States (? Help Context Tooltip)

An integrated context button (?) provides instantaneous documentation for agents on the behavioral mechanics of the local cache machine:

    REACHABLE: The operating system has positive, recent validation that the destination device is online and responsive. Packets route instantly with no communication overhead.

    PROBE: The entry's guaranteed reachability timer has expired. The OS is currently sending direct, unicast verification requests straight to that cached MAC address to confirm the node has not changed physical switch ports or dropped off-line.

    PERMANENT: A static, unexpiring hardcoded relationship mapping. This is universally reserved for local loopbacks, broadcast matrices, and statically pinned default gateway equipment.

🌐 WAN & ISP Triage Engine

Designed for fast triage of remote home workers or remote satellite branches experiencing performance issues or split-tunneling VPN failures.

    WAN Discovery: Queries external endpoints (icanhazip.com and ipinfo.io/json) using non-blocking API web calls to pull the station's active public-facing WAN IP address, registered Internet Service Provider (ISP) network organization, and physical geolocated city and country data.

    Gateway & Backbone Verifications: Dynamically identifies the host workstation's primary local gateway interface hop, then executes a structured sequence running a 3-packet verification check out to the local gateway, Google Public DNS infrastructure (8.8.8.8), and Cloudflare DNS infrastructure (1.1.1.1). It returns a clear metric indicating active REACHABLE / UNREACHABLE statuses and calculates precise, rounded Average Latency (ms) data.

📁 Automation & Logging Architecture

Every tool inside the Unified Network Diagnostic Suite maintains consistent, programmatic file output patterns. Logs are structured natively to allow technicians to rapidly extract configuration states or batch-collect data files for escalated engineering support.

Logs are arranged dynamically by date inside a local directory path layout:
```
C:\\temp\\
 ├── quick_dns\\<yyyy-MM-dd>\\<HH-mm-ss>.txt
 ├── quick_netstat\\<yyyy-MM-dd>\\<HH-mm-ss>.txt
 ├── quick_pinglog\\<yyyy-MM-dd>\\<HH-mm-ss>.txt
 ├── quick_portscan\\<yyyy-MM-dd>\\<HH-mm-ss>.txt
 ├── quick_tracert\\<yyyy-MM-dd>\\<HH-mm-ss>.txt
 ├── quick_sysprofile\\<yyyy-MM-dd>\\<HH-mm-ss>.txt
 ├── quick_eventlog\\<yyyy-MM-dd>\\<HH-mm-ss>.txt
 ├── quick_account\\<yyyy-MM-dd>\\<HH-mm-ss>.txt
 ├── quick_adapter\\<yyyy-MM-dd>\\<HH-mm-ss>.txt
 ├── quick_isptriage\\<yyyy-MM-dd>\\<HH-mm-ss>.txt
 └── quick_arp\\<yyyy-MM-dd>\\<HH-mm-ss>.csv     <-- Structured Data Output
```
CSV Output Design

While other profiling utilities drop their data records into clean unstructured text views inside their respective folders, the ARP Discovery tool converts the underlying PowerShell pipeline objects directly into an active tabular data structure via Export-Csv -NoTypeInformation -Encoding UTF8.

This outputs standard comma-separated columns (IPAddress, LinkLayerAddress, State) completely clean of metadata tags, allowing administrators to immediately ingest logs into Microsoft Excel, databases, or programmatic infrastructure tracking modules.
🛡️ Git & Security Compliance

This diagnostic toolset is entirely generic, modular, and built exclusively on dynamic system discovery patterns.

    No Statically Hardcoded Secrets: There are no embedded enterprise passwords, corporate API authentication keys, or static localized IP targets.

    Repository Safe: It is entirely safe to upload, fork, or track this script suite in public source control environments (such as public GitHub or GitLab repositories).

    Compliance Suggestion: If modifications are made locally to pre-populate text controls with internal corporate asset ranges or names for tech convenience, ensure a proper .gitignore configuration masks local logging paths or temporary testing branches before initiating upstream pushes.
    """
```
with open("README.md", "w", encoding="utf-8") as f:
f.write(readme_content)

print("Successfully written README.md file.")
```
