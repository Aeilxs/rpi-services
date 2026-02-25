# Homelab Roadmap — Alexis (V2.0)

## Phase 1 — Fondations & Data Safety
- Objectif : Zéro perte de données et intégrité du système.

[x] Pinning des versions Docker (Adieu :latest)
[x] Backup Vaultwarden (Mode PULL via Mac + SSH restreint)
[x] Audit des logs & Rotation (Logrotate configuré)
[x] Documenter la procédure de recovery (Testée avec succès)
[x] Persistence et backup du dossier /data/caddy (Sauvegarder ta CA locale)
~~[ ] Migration backup Vaultwarden vers API Admin~~
> sqlite3 pour la migration à chaud donc pas de API Admin.

## Phase 2 — Core Services & Networking

- Objectif : Supprimer la maintenance manuelle et centraliser le flux réseau.
[x] Déploiement AdGuard Home (DNS local en container)
[x] DNS Rewriting : Configurer *.home vers l'IP du tunnel (adieu `/etc/hosts`)
[x] Intégration WireGuard : Pousser le DNS AdGuard aux clients VPN (`DNS = 10.10.0.1`)
[x] Healthchecks : Ajouter des tests de santé dans tous les docker-compose.yaml
[x] HTTPS Interne : Finaliser la confiance des certs Caddy sur les devices clients

## Phase 3 — Observabilité & MCO (Maintien en Condition Opérationnelle)
- Objectif : Ne plus deviner, mais savoir.

[x] Stack Monitoring (Prometheus / Grafana)
[x] Node Exporter & cAdvisor : Métriques Host et Conteneurs
[x] Centralisation des logs (Loki)
~~ [ ] Alerting critique : Bot Telegram (Alerte si disque > 90% ou service Down) ~~
> Pas super utile pour le moment vu qu'on est tjs en développement donc on va gérer avant tout la Phase 4 qui commence à être essentielle.

## Phase 4 — Industrialisation & IaC

- Objectif : Reproductibilité totale et standard professionnel.
[x] Playbook Ansible : Automatiser le bootstrap de la Pi (Security, Docker, Arborescence)
[x] Secrets Management : Migration vers SOPS ou Vault (Zéro secret en clair sur Git)
[x] Structure /srv documentée et reproductible en une commande
~~ [ ] CI/CD Light : Linting des fichiers Compose via GitHub Actions / Gitea ~~
> Bof pour le moment j'ai envie de faire d'autres choses plus funs et utiles, on verra ça plus tard. C'est un homelab perso après tout et on est déjà carré sur la partie sécurité et backup, c'est le plus important.

## Phase 5 — Sécurité & Audit (Hardening)

- Objectif : Niveau de sécurité "prod".
[x] Audit des permissions : Rootless containers quand c'est possible
- Doing
~~[ ] Protection périmétrique : Fail2ban (SSH) et CrowdSec (Caddy)~~
- fail2ban inutile, pas de port 22 ouvert et SSH en key-only
- crowdsec tldr: usine à gaz pour pas grand chose, pas de client, ça impliquerait qu'un de mes devices est compromis pour que ça ait un intérêt, et dans ce cas là j'ai d'autres problèmes plus urgents à régler 😭
[x] Vulnerability Scanning : Trivy pour scanner les images fixées
[x] Network Hardening : Isolation des réseaux Docker
