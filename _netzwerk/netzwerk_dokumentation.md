# Netzwerkdokumentation - Ist-Zustand nach UCGF-Migration

## 1. Kontext

- Produktiv-LAN weiterhin `192.168.178.0/24`
- UniFi Cloud Gateway Fiber (UCGF) uebernimmt Routing, DHCP und die zentrale Netzwerksteuerung
- FRITZ!Box 7590 AX bleibt als Upstream-Gateway/NAT im Vornetz `192.168.180.0/24`
- QNAP bleibt zentraler DNS- und Service-Host fuer das interne Netz

## 2. Logische Topologie

```text
Internet
-> FRITZ!Box 7590 AX (192.168.180.1, Upstream-Gateway / NAT)
-> UCGF WAN (DHCP im 192.168.180.0/24)
-> UCGF LAN / Gateway 192.168.178.1
-> TL-SX105 (Uplink / Unterverteilung im Abstellraum)
-> TL-SX1008 (Core Switch im Gastzimmer)
-> Infrastruktur, Clients und Powerline
```

## 3. Infrastruktur und Adressierung

| Komponente | IP-Adresse | Rolle |
| --- | --- | --- |
| UCGF | 192.168.178.1 | Router / DHCP / zentrales Gateway |
| FRITZ!Box 7590 AX | 192.168.180.1 | Upstream-Gateway / NAT / Exposed-Host-Ziel fuer UCGF |
| QNAP NAS | 192.168.178.10 | AdGuard DNS / Docker / Reverse Proxy `:81` |
| Home Assistant | 192.168.178.11 / .12 | Automation |
| UniFi Controller | 192.168.178.14 | QNAP-VM / Ubuntu / WLAN-Verwaltung |
| UniFi APs | 192.168.178.4 / .8 / .9 | WLAN-Infrastruktur |
| DHCP-Clients | 192.168.178.100 - 192.168.178.200 | Standard-Clientnetz laut UCGF-Diagramm |

## 4. Physische Verteilung

### Abstellraum

- DSL-Anschluss -> FRITZ!Box 7590 AX -> UCGF -> TL-SX105
- Direkt am TL-SX105: Home Assistant sowie die Uplinks nach Gast-, Wohn- und Schlafzimmer

### Gastzimmer

- LAN-Dose Gast -> TL-SX1008 als Core Switch
- Direkt am TL-SX1008: QNAP (10G), Mac mini M2 (10G), Laptop (10G), Canon PRO-1000, QNAP 2.5G und Yuanley YS25-0801
- Am Yuanley-Switch: U7-Pro (via PoE+-Adapter), HP OfficeJet Pro 9022e und Fernseher

### Wohnzimmer

- LAN-Dose Wohn -> TrendNet TPE-TG327
- Am TrendNet-Switch: U7-Pro Wall, MQTT-Antenne, OpenCCU-Antenne, Fernseher und Vodafone-TV-Box

### Schlafzimmer

- LAN-Dose Schlaf -> PoE+-Adapter -> U7-Pro

## 5. WLAN

### Smallnet

- 5 GHz / 6 GHz
- WPA3

### smallnet-5g

- 5 GHz
- WPA2/WPA3

### smallnet-iot

- 2.4 GHz
- WPA2
- auf ausgewaehlte APs begrenzt

## 6. Architekturhinweise

- Das interne LAN-Subnetz wurde bei der Migration nicht geaendert.
- Double NAT ist aktuell bewusst aktiv.
- IPv6 ist derzeit bewusst deaktiviert.
- DNS fuer Clients zeigt weiterhin auf `192.168.178.10` (QNAP / AdGuard).
- Es sollen keine Produktiv-Clients direkt an der FRITZ!Box betrieben werden.
- Die Powerline-Strecke fuer Keller/Waschmaschine haengt jetzt hinter UCGF und Switch-Infrastruktur.

## 7. Migration und Zielbild

### Migrationsergebnis

- Vor der Migration war die FRITZ!Box Gateway und DHCP-Server des Produktiv-LANs.
- Nach der Migration uebernimmt die UCGF diese Aufgaben, ohne das LAN-Subnetz oder die bekannten internen IPs zu veraendern.

### Zielbild fuer FTTH

- Geplant ist `ONT -> UCGF` direkt.
- In diesem Zielbild entfaellt die FRITZ!Box als Upstream-Gateway.

## 8. Validierungscheckliste

- UCGF-LAN-Gateway ist `192.168.178.1`.
- FRITZ!Box ist nur noch im Upstream-Netz `192.168.180.0/24` sichtbar.
- DNS fuer Clients zeigt auf `192.168.178.10`.
- Home Assistant, QNAP, UniFi Controller und APs sind weiterhin unter den bekannten LAN-Adressen erreichbar.
- Powerline ist nicht parallel an der FRITZ!Box angebunden.
