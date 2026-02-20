# 🌐 Networking & VPN Gateway (WireGuard)

## 🛠️ Configuration de la Box

L'accès au Homelab est restreint par une politique **Zero-Exposure** : aucun port web (80/443) n'est ouvert. Seul le tunnel WireGuard est autorisé.

### 🔀 Règle NAT/PAT

En raison de l'assignation d'IP partagées sur certaines lignes Free, la plage de ports peut être restreinte.

- **Port Externe :** `5182` (UDP)
- **Port Interne :** `51820` (UDP) -> `192.168.1.48` (Raspberry Pi)

### 📌 IP

- **DHCP Statique :** 
    - wlan0 `192.168.1.48`.
    - eth0 `192.168.1.146`.
- **UPnP :** Désactivé pour garantir un contrôle total sur l'ouverture des flux.

## 🛠️ Serveur WireGuard (Host)

Le serveur agit comme la passerelle du réseau `10.10.0.0/24`.

### Configuration (`/etc/wireguard/wg0.conf`)

```ini
[Interface]
Address = 10.10.0.1/24
ListenPort = 51820
PrivateKey = <SERVER_PRIVATE_KEY>

[Peer] # Client exemple
PublicKey = <CLIENT_PUBLIC_KEY>
AllowedIPs = 10.10.0.2/32
```

### Opérations courantes

- **Redémarrage :** `sudo systemctl restart wg-quick@wg0`
- **Status des tunnels :** `sudo wg show`
- **Vérification de l'écoute :** `sudo ss -lunp | grep 51820`

## 🛠️ Configuration Client

Le client doit rediriger le trafic destiné au Homelab via le tunnel tout en maintenant son accès internet habituel (Split Tunneling).

### Tunnel Client (`config.conf`)

```ini
[Interface]
PrivateKey = <CLIENT_PRIVATE_KEY>
Address = 10.10.0.2/32
DNS = 10.10.0.1

[Peer]
PublicKey = <SERVER_PUBLIC_KEY>
Endpoint = <PUBLIC_IP>:5182
AllowedIPs = 10.10.0.0/24 # Accès uniquement au sous-réseau VPN
PersistentKeepalive = 25 # Maintient le tunnel actif même derrière NAT
```