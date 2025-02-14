# C2Lab

- C2Lab - A lightweight and customizable Command &amp; Control (C2) lab using Sliver for testing and analyzing botnet communications, persistence, and network detection techniques.

## 🚀 Project Overview

- This lab demonstrates how to set up a **C2 infrastructure using Sliver****, deploy bots, establish communication over mTLS, and implement persistence** while capturing network **traffic for analysis.**
<img src="assets/sliver_framework.jpg" width="400" alt="Sliver C2 Framework Logo" />

## 🛠 Features

- **Terraform (IaC) automation** for deploying the **C2 server and botnet machines.**
- **mTLS-secured C2 communication** over port **443.**
- **Fake website hosting** for social engineering.
- **Persistent reverse shell** with a **systemd service.**
- **PCAP captures** for analyzing C2 and bot interactions.
- **Detection techniques** for identifying encrypted C2 traffic.

## 📌 Steps Performed

1️⃣ **Infrastructure Deployment**
- Used Terraform to deploy:
  - C2 Machine
  - Botnet Machines (2 bots)
