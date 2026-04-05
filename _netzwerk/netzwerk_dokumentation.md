# Netzwerkdokumentation - Ist-Zustand nach UCGF-Migration und VLAN-Einfuehrung

## 1. Kontext

- Produktiv- und Vertrauensnetz bleibt `192.168.178.0/24`.
- UniFi Cloud Gateway Fiber (UCGF) uebernimmt Routing, DHCP, WLAN-Zuordnung und die zonenbasierte Firewall.
- FRITZ!Box 7590 AX bleibt als Upstream-Gateway / NAT im Vornetz `192.168.180.0/24`.
- QNAP bleibt zentraler DNS- und Service-Host fuer interne Netze.
- Die VLAN-Einfuehrung ist bereits fuer WLAN aktiv. Die geplante Umruestung der physischen Switch-Infrastruktur auf mehr UniFi-Managed-Switching ist davon getrennt und noch nicht der dokumentierte Ist-Zustand.

## 2. Logische Topologie

```text
Internet
-> FRITZ!Box 7590 AX (192.168.180.1, Upstream-Gateway / NAT)
-> UCGF WAN (DHCP im 192.168.180.0/24)
-> UCGF LAN / Gateway 192.168.178.1
-> Bestehende Switch-Infrastruktur / AP-Uplinks
-> Virtuelle Netze und SSIDs
   - Trusted / Default   192.168.178.0/24
   - IoT / VLAN 20       10.10.20.0/24
   - Guest / VLAN 30     10.10.30.0/24
```

## 3. Netze und Adressierung

| Netz | Subnetz | Gateway | Zweck |
| --- | --- | --- | --- |
| Trusted / Default | `192.168.178.0/24` | `192.168.178.1` | Hauptnetz fuer Benutzergeraete, Drucker, Scanner, Medien, Infrastruktur |
| IoT | `10.10.20.0/24` | `10.10.20.1` | Echo, Echo Show, WLED, ESPHome, Roborock, L900 und weitere Smart-Home-Geraete |
| Guest | `10.10.30.0/24` | `10.10.30.1` | reines Gastnetz |
| Upstream / WAN | `192.168.180.0/24` | FRITZ!Box | Vornetz zwischen FRITZ!Box und UCGF |

## 4. Infrastruktur und feste Dienste

| Komponente | IP-Adresse | Rolle |
| --- | --- | --- |
| UCGF | `192.168.178.1` | Router / DHCP / VLAN-Gateway / Firewall |
| FRITZ!Box 7590 AX | `192.168.180.1` | Upstream-Gateway / NAT / Exposed-Host-Ziel fuer UCGF |
| QNAP NAS | `192.168.178.10` | AdGuard DNS / Docker / Reverse Proxy `:81` |
| Home Assistant | `192.168.178.12` | Automation / zentrale Steuerung |
| UniFi APs | bekannte Infrastrukturadressen im Trusted-Netz | WLAN-Infrastruktur |

Hinweise:

- Die fruehere separate UniFi-Controller-VM auf dem QNAP ist nicht mehr Bestandteil des Ist-Zustands. Die UniFi-Verwaltung liegt jetzt am UCGF.
- DNS fuer Clients zeigt weiterhin auf `192.168.178.10` (QNAP / AdGuard), auch fuer das IoT-Netz.

## 5. SSID- und Rollenmodell

### Smallnet

- Netz: `Trusted / Default`
- Frequenzbaender: `2.4 GHz`, `5 GHz`, `6 GHz`
- Sicherheit: `WPA2/WPA3`
- Zweck: Benutzergeraete, Drucker, Scanner, Teufel Radio, MagentaTV und weitere vertrauenswuerdige Endgeraete
- `MLO` ist bewusst deaktiviert, weil damit in der Praxis Instabilitaeten aufgetreten sind

### smallnet-iot

- Netz: `IoT`
- Frequenzbaender: `2.4 GHz`
- Sicherheit: `WPA2`
- Zweck: Smart-Home- und Assistant-Geraete
- bewusst ohne Roaming- und WiFi-7-Experimente

### Guest

- Netz: `Guest`
- Frequenzbaender: `2.4 GHz`, `5 GHz`
- Sicherheit: `WPA2/WPA3`
- Zweck: Besuchergeraete

### smallnet-5g

- nicht mehr Teil des Zielbilds
- nur noch als Uebergangs- / Legacy-SSID betrachten, solange sie noch existiert

## 6. Aktuelle Geraetezuordnung

### IoT

- Echo Bad
- Echo Gast
- Echo Wohn
- Echo-Show
- esphome-web-e37ea4
- L900
- roborock-vacuum-a288
- wled-WLED
- wled-WLED-SoundReactive (beide Instanzen)

### Trusted

- EPSON-ES-580W
- HP Pro 9022e
- Galaxy-Tab-S6-Lite
- iPad
- MagentaTV
- S24-Ultra (beide Geraete)
- Tab-S10-Ultra
- Teufel RADIO 3SIXTY

### Guest

- keine festen Haushaltsgeraete
- nur Besuchergeraete

## 7. Firewall und Betriebsmodell

### Aktive Uebergangsregeln

- `Allow IoT to QNAP DNS`
- `Allow Trusted to IoT`
- `Allow HA to Roborock UDP 58866`
- `Allow HA to Roborock TCP 58867`

### Bedeutung

- `IoT -> QNAP DNS` erlaubt DNS-Aufloesung gegen `192.168.178.10`.
- `Trusted -> IoT` ist aktuell noch bewusst breit, damit die VLAN-Einfuehrung ohne harte Brueche erfolgen kann.
- Fuer Roborock sind die lokalen Home-Assistant-Freigaben auf `UDP 58866` und `TCP 58867` notwendig, damit die Integration nicht auf die Cloud-API zurueckfaellt.

### Wichtige Betriebsregel

- VLAN-uebergreifendes `mDNS` wird nicht als zuverlaessige Grundlage eingeplant.
- Lokal integrierte IoT-Geraete arbeiten daher mit festen DHCP-Reservations und bei Bedarf nachgezogenen Ziel-IPs in Apps und Integrationen.

## 8. Physischer Ist-Zustand

- Die physische Grundstruktur aus UCGF, bestehender Switch-Infrastruktur und den drei U7-AP-Pfaden bleibt derzeit bestehen.
- Die VLAN-Einfuehrung betrifft aktuell vor allem die WLAN-Segmente ueber die U7-APs.
- Die geplante spaetere Umruestung auf mehr UniFi-Managed-Switching ist ein eigener naechster Ausbauschritt und nicht Bestandteil dieses dokumentierten Zustands.

## 9. Architekturhinweise

- Das Trusted-LAN-Subnetz wurde bei der Migration und auch bei der VLAN-Einfuehrung nicht geaendert.
- Double NAT ist aktuell bewusst aktiv.
- IPv6 ist derzeit bewusst deaktiviert.
- Es sollen keine Produktiv-Clients direkt an der FRITZ!Box betrieben werden.
- Apps wie WLED muessen nach einem echten VLAN-Umzug auf die neue feste IoT-IP zeigen.
- Home Assistant kennt die migrierten IoT-Geraete wieder und Alexa steuert diese Geraete weiterhin ueber Home Assistant.

## 10. Zielbild

### Aktuelles Zielbild nach WLAN-VLAN-Einfuehrung

- `Smallnet` bleibt die eine Trusted-SSID.
- `smallnet-iot` bleibt die eine IoT-SSID.
- `Guest` bleibt das Gastnetz.
- `smallnet-5g` soll mittelfristig entfallen.

### Naechster Ausbauschritt

- spaetere Umruestung der Switch-Infrastruktur auf mehr UniFi-Managed-Switching
- damit saubere VLAN-Fuehrung auch fuer mehr kabelgebundene Segmente

### Zielbild fuer FTTH

- geplant ist `ONT -> UCGF` direkt
- in diesem Zielbild entfaellt die FRITZ!Box als Upstream-Gateway

## 11. Validierungscheckliste

- `Smallnet` haengt im Trusted-Netz `192.168.178.0/24`.
- `smallnet-iot` haengt im IoT-Netz `10.10.20.0/24`.
- `Guest` haengt im Gastnetz `10.10.30.0/24`.
- IoT-Geraete erhalten `10.10.20.x` und sind in Home Assistant erreichbar.
- Alexa steuert die ueber Home Assistant freigegebenen Geraete weiterhin.
- Roborock arbeitet lokal in Home Assistant und faellt nicht auf die Cloud-API zurueck.
- DNS fuer interne Netze zeigt weiterhin auf `192.168.178.10`.

