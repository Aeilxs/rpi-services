# Homelab Changelog

## [11-02-2026] - Phase 1 Clôturée : Data Safety & Resilience

- Script de snapshot sur la Pi (`backup_vaultwarden.sh`) avec backup à chaud de SQLite.
- Script de pull sur Mac (`pull_backup.sh`) avec gestion des fallbacks SSH (VPN/Eth/Wlan).
- Procédure de recovery complète sur Mac via Docker Colima.
- Rétention par occurrences : 3 sur la Pi, 10 sur le Mac.

---

## [12-02-2026] - Phase 2 Clôturée : Core Services & Networking

- DNS en place via Adguard.
    - Wildcard *.home pour rewriting DNS.
- Healtchecks sur 100% des containers.
- HTTPS partout, CA locale OK.
- Corrections :
    - Passage en mode PULL à partir du mac pour plus de sécurité et de flexibilité. Suppression de la clé SSH Pi -> Mac (anciennement `id_ed25519_backup_service`)
    - Alignement des logs au format ISO 8601 pour future ingestion Loki.

---

## [13-02-2026] - Phase 3 Clôturée : Monitoring

- Reste à faire les healtchecks pour certaines images, `curl` et `wget` pas présent (img distroless ?). J'ai pas cherché beaucoup plus loin, mais peut être avec `/dev/tcp` plus tard.
- Finir de bien gérer les logs. `qbittorrent` et d'autres containers ne sont pas forcément visibles pour `Loki` et `Promtail` ce qui est un peu pénible !

---

## [19-02-2026] - Phase 4 Clôturée : IaC, SRE & Cold Backup

- Migration vers Ansible pour la gestion des permissions et le déploiement.
- Un test effectué sur la Pi pour vérifier que les données stateful sont bien préservées après un cycle `down -> tar -> up` du stack et qu'un redéploiement via Ansible ne cause pas de corruption.
- Uniformisation de Caddy (utilisait les volumes docker pour les configs) : maintenant tout est dans `/srv/services/caddy/{data,config}`
- Implémentation du "Cold Backup" : script `backup.sh` avec cycle `down -> tar -> up`.
- Résolution définitive des corruptions Loki/Prometheus via arrêt complet des stacks.
    - `stop` et `start` ne sont pas suffisant pour Loki/Prometheus qui gardent des fichiers ouverts, d'où l'arrêt complet des stacks.
- Standardisation des permissions : boucle Ansible pour les UIDs spécifiques (Loki, Grafana, Prometheus).
- Ajout de `stack.sh` : Outil CLI pour la gestion globale des services.