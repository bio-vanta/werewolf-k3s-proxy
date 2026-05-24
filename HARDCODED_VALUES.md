# ค่าที่ Hard Code ในโปรเจกต์

## 🔴 ค่าที่ควรแก้ไขก่อนใช้งาน (Critical)

### 1. **Email สำหรับ Let's Encrypt** 
📁 `01-bootstrap/cluster-issuer.yaml`
```yaml
email: pjame.fb@gmail.com  # ⚠️ ต้องเปลี่ยนเป็น email ของคุณ
```
**ผลกระทบ:** ใช้สำหรับรับการแจ้งเตือนเกี่ยวกับ SSL certificates

---

### 2. **Email สำหรับ Gitea Admin**
📁 `01-initial-secrets.bash`
```bash
--from-literal=email=admin@example.com  # ⚠️ ควรเปลี่ยนเป็น email จริง
```
**ผลกระทบ:** ใช้เป็น email ของ Gitea admin account

---

## 🟡 ค่าที่เกี่ยวข้องกับ Infrastructure (ควรตรวจสอบ)

### 3. **Storage Path**
📁 `00-install-k3s.bash`
```bash
--default-local-storage-path "/data"
```
**ผลกระทบ:** ตำแหน่งเก็บข้อมูล persistent volumes ทั้งหมด

---

### 4. **K3s Installation URL**
📁 `00-install-k3s.bash`
```bash
curl -sfL https://get.k3s.io | sh -s -
```
**ผลกระทบ:** URL สำหรับดาวน์โหลด K3s installer

---

### 5. **Kubeconfig Path**
📁 `00-install-k3s.bash`
```bash
sudo cp /etc/rancher/k3s/k3s.yaml $HOME/k3s.yaml
```
**ผลกระทบ:** ตำแหน่งที่เก็บ kubeconfig file

---

## 🟢 Docker Images (ควรตรวจสอบเวอร์ชัน)

### 6. **Secret Manager Job Image**
📁 `00-configs/initial-secret.yaml`
```yaml
image: asia-southeast1-docker.pkg.dev/its-artifact-commons/please-protect/please-protect-jobs:v0.0.14
```
**ผลกระทบ:** Image สำหรับสร้าง initial secrets

---

### 7. **Git Sync Job Image**
📁 `01-bootstrap/git-sync-job.yaml`
```yaml
image: asia-southeast1-docker.pkg.dev/its-artifact-commons/utils/git-sync:v0.0.2
```
**ผลกระทบ:** Image สำหรับ sync repositories จาก GitHub ไป Gitea

---

## 🔵 Git Repositories (เฉพาะองค์กร)

### 8. **GitHub Organization & Repositories**
📁 `04-boot-strap.bash`
```bash
DATA_PLANE_REMOTE_REPO=https://github.com/wintech-thai/please-protect-rproxy-data-plane.git
# CTRL_PLANE_REMOTE_REPO=https://github.com/wintech-thai/please-protect-rproxy-control-plane.git (commented)
```

📁 `01-bootstrap/git-sync-job.yaml`
```yaml
GIT_SOURCE_TEMPLATE: "https://github.com/wintech-thai/{repo}.git"
GIT_SOURCE_REPO1: "please-protect-rproxy-data-plane"
```

📁 `01-bootstrap/argocd-local-repo.yaml`
```yaml
url: https://github.com/wintech-thai/please-protect-rproxy-data-plane.git
url: https://github.com/wintech-thai/please-protect-rproxy-control-plane.git
```

**ผลกระทบ:** ต้องเปลี่ยนเป็น GitHub organization และ repositories ของคุณเอง

---

## 🟣 Helm Repositories & Versions

### 9. **ArgoCD Helm Chart**
📁 `00-configs/addons-argocd.yaml`
```yaml
repo: https://argoproj.github.io/argo-helm
chart: argo-cd
version: 9.1.9
```

---

### 10. **Ingress NGINX Helm Chart**
📁 `00-configs/addons-ingress.yaml`
```yaml
repo: https://kubernetes.github.io/ingress-nginx
chart: ingress-nginx
version: 4.14.1
```

---

### 11. **Cert-Manager Helm Chart**
📁 `00-configs/addons-cert-manager.yaml`
```yaml
repo: https://charts.jetstack.io
chart: cert-manager
version: 1.19.2
```

---

### 12. **External Secrets Helm Chart**
📁 `00-configs/addons-external-secret.yaml`
```yaml
repo: https://charts.external-secrets.io
chart: external-secrets
version: 1.1.1
```

---

### 13. **Gitea Helm Chart**
📁 `00-configs/addons-gitea.yaml`
```yaml
repo: https://dl.gitea.com/charts/
chart: gitea
```

---

### 14. **Prometheus Stack Helm Chart**
📁 `03-install-monitoring.bash`
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm template kube-prometheus-crds prometheus-community/kube-prometheus-stack --version 76.4.0
```

---

## 🟤 Internal Service URLs

### 15. **Gitea Internal URL**
📁 `00-configs/addons-gitea.yaml`
```yaml
ROOT_URL: http://gitea-http.gitea.svc.cluster.local:3000
```

📁 `01-bootstrap/argocd-bootstrap-data-plane.yaml`
```yaml
repoURL: http://gitea-http.gitea.svc.cluster.local:3000/local/data-plane.git
```

📁 `01-bootstrap/argocd-local-repo.yaml`
```yaml
url: http://gitea-http.gitea.svc.cluster.local:3000/local/data-plane.git
url: http://gitea-http.gitea.svc.cluster.local:3000/local/control-plane-dev.git
url: http://gitea-http.gitea.svc.cluster.local:3000/local/control-plane-prod.git
```

📁 `01-bootstrap/git-sync-job.yaml`
```yaml
GITEA_BASE_URL: "http://gitea-http.gitea.svc.cluster.local:3000"
GIT_DEST_TEMPLATE: "http://gitea-http.gitea.svc.cluster.local:3000/{repo}.git"
```

**ผลกระทบ:** URL ภายใน cluster สำหรับเข้าถึง Gitea

---

### 16. **ArgoCD Cluster Server URL**
📁 `01-bootstrap/argocd-cluster-secret.yaml`
```yaml
server: https://notused
```
**หมายเหตุ:** ใช้ค่า dummy เพราะ deploy ใน cluster เดียวกัน

---

### 17. **AlertManager Webhook (Commented)**
📁 `03-monitoring/alm-config.yaml`
```yaml
# url: 'http://pp-prod-pp-api.pp-production.svc.cluster.local/api/AlertEvent/org/default/action/Notify'
```
**หมายเหตุ:** ถูก comment ไว้ แต่ถ้าจะใช้ต้องแก้ URL

---

## 🟠 Namespaces

### 18. **Hardcoded Namespaces**
- `default` - สำหรับ initial secrets
- `gitea` - สำหรับ Gitea
- `argocd` - สำหรับ ArgoCD
- `monitoring` - สำหรับ Prometheus/Grafana
- `kube-system` - สำหรับ Helm charts

---

## ⚫ Git Sync Configuration

### 19. **Git Sync Repositories & Branches**
📁 `01-bootstrap/git-sync-job.yaml`
```yaml
# Source (GitHub)
GIT_SOURCE_REPO1: "please-protect-rproxy-data-plane"
GIT_SOURCE_REPO2: ""  # Skip control plane
GIT_SOURCE_REPO3: ""  # Skip control plane

# Branches
GIT_SOURCE_REF_NAME1: "main"
GIT_SOURCE_REF_NAME2: "development"
GIT_SOURCE_REF_NAME3: "production"

# Destination (Gitea)
GIT_DEST_REPO1: "local/data-plane"
GIT_DEST_REPO2: "local/control-plane-dev"
GIT_DEST_REPO3: "local/control-plane-prod"

GIT_DEST_REF_NAME1: "main"
GIT_DEST_REF_NAME2: "development"
GIT_DEST_REF_NAME3: "production"
```

---

## 🔧 Grafana Configuration

### 20. **Grafana URL Path**
📁 `03-monitoring/prometheus-values.yaml`
```yaml
root_url: "%(protocol)s://%(domain)s/tools/grafana-k8s"
serve_from_sub_path: true
```
**ผลกระทบ:** Grafana จะ serve ที่ path `/tools/grafana-k8s`

---

## 📊 สรุปค่าที่ต้องแก้ไขตามลำดับความสำคัญ

### 🔴 สำคัญมาก (ต้องแก้)
1. ✅ **Email ใน cluster-issuer.yaml** → เปลี่ยนเป็น email ของคุณ
2. ✅ **Email ใน initial-secrets.bash** → เปลี่ยนเป็น email ของคุณ
3. ✅ **GitHub repositories** → เปลี่ยนเป็น repos ของคุณเอง

### 🟡 สำคัญปานกลาง (ควรตรวจสอบ)
4. ⚠️ **Docker images versions** → ตรวจสอบว่ามี access และเวอร์ชันถูกต้อง
5. ⚠️ **Storage path `/data`** → ตรวจสอบว่ามี space เพียงพอ
6. ⚠️ **Helm chart versions** → พิจารณาอัพเดทเป็นเวอร์ชันล่าสุด

### 🟢 ไม่จำเป็นต้องแก้ (ใช้ค่า default ได้)
7. ✓ **Internal service URLs** → ใช้ค่า default ได้
8. ✓ **Namespaces** → ใช้ค่า default ได้
9. ✓ **Grafana path** → ใช้ค่า default ได้

---

## 💡 คำแนะนำ

### วิธีทำให้ค่าเหล่านี้ configurable:

1. **สร้างไฟล์ config.env** สำหรับค่าที่ต้องการปรับแต่ง:
```env
# Email Configuration
LETSENCRYPT_EMAIL=your-email@example.com
GITEA_ADMIN_EMAIL=admin@your-domain.com

# GitHub Configuration
GITHUB_ORG=your-github-org
DATA_PLANE_REPO=your-data-plane-repo
CONTROL_PLANE_REPO=your-control-plane-repo

# Storage Configuration
K3S_STORAGE_PATH=/data

# Docker Registry
DOCKER_REGISTRY=asia-southeast1-docker.pkg.dev/your-project
```

2. **แก้ไข scripts ให้อ่านค่าจาก config.env**:
```bash
source config.env
sed -i "s|pjame.fb@gmail.com|${LETSENCRYPT_EMAIL}|g" 01-bootstrap/cluster-issuer.yaml
```

3. **ใช้ environment variables แทน hard code**:
```bash
EMAIL=${LETSENCRYPT_EMAIL:-pjame.fb@gmail.com}
```

---

## ⚠️ Security Notes

1. **อย่า commit ไฟล์ `.env`** ที่มี credentials เข้า Git
2. **เปลี่ยน passwords ทั้งหมด** ก่อนใช้งาน production
3. **ตรวจสอบ Docker images** ว่ามาจาก registry ที่เชื่อถือได้
4. **ใช้ private registry** สำหรับ production images
5. **Enable RBAC** และจำกัด permissions ตามความจำเป็น
