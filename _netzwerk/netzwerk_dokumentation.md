# Netzwerkdokumentation – Ist-Zustand

## 1. Übersicht

**Netzwerkname:** Heimnetz  
**Subnetz:** 192.168.178.0/24  

**Gateway:**  
- FRITZ!Box 7590 AX – 192.168.178.1  

**DHCP:**  
- Bereich: 192.168.178.90 – 192.168.178.199  

**DNS:**  
- 192.168.178.10 (NAS)  

---

## 2. Topologie

```
Internet → FRITZ!Box → SX1008 (Core Switch)

Vom Core Switch:
- NAS (DNS)
- Home Assistant (2 Instanzen)
- UniFi Controller (Mac mini)
- Clients
- UniFi Infrastruktur

Separat:
Powerline → Keller → Waschmaschine
```

---

## 3. Infrastruktur

| Komponente          | IP-Adresse        | Rolle                |
|--------------------|------------------|----------------------|
| FRITZ!Box          | 192.168.178.1    | Gateway / DHCP       |
| NAS (QNAP)         | 192.168.178.10   | DNS / Storage        |
| Home Assistant     | .11 / .12        | Automation           |
| UniFi Controller   | 192.168.178.14   | WLAN Management      |
| Access Points      | .4 / .8 / .9     | WLAN                 |

---

## 4. WLAN

### Smallnet
- 5 GHz / 6 GHz
- WPA3

### smallnet-5g
- 5 GHz
- WPA2/WPA3

### smallnet-iot
- 2.4 GHz
- WPA2
- eingeschränkt auf ausgewählte APs

---

## 5. Architektur

- Routing: FRITZ!Box  
- DHCP: FRITZ!Box  
- UniFi: Layer-2 Infrastruktur (Bridge Mode)  

**Powerline:**
- isolierter Einsatz (Waschmaschine im Keller)

---

## 6. Bewertung

- klare Layer-3 Struktur  
- saubere IP-Planung  
- getrennte WLAN-Profile  
- kein Double NAT  

→ Architektur ist konsistent und wartbar
