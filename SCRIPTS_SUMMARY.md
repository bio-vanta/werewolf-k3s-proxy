# สรุปการทำงานของ Bash Scripts

## ภาพรวม
โปรเจกต์นี้เป็นการติดตั้งและตั้งค่า K3s Kubernetes cluster พร้อมกับ addons ต่างๆ เช่น ArgoCD, Gitea, Ingress, Cert-Manager, External Secrets และ Monitoring (Prometheus/Grafana)

---

## 📋 ลำดับการรัน Scripts

### 1. `00-install-k3s.bash`
**หน้าที่:**
- ติดตั้ง K3s Kubernetes cluster
- ตั้งค่า cluster ในโหมด cluster-init (สำหรับ HA)
- ปิดการใช้งาน Traefik (ใช้ Ingress อื่นแทน)
- เปิดใช้งาน etcd metrics
- คัดลอก kubeconfig ไปที่ home directory

**ค่าที่ต้องการจาก User:**
- ไม่มี (ใช้ค่า default)
- แต่ต้องมี directory `/data` สำหรับ local storage

**คำสั่งที่รัน:**
```bash
./00-install-k3s.bash
```

---

### 2. `01-initial-secrets.bash`
**หน้าที่:**
- สร้าง initial secrets สำหรับระบบ
- สร้าง secret สำหรับ Gitea admin
- อ่านค่าจากไฟล์ `.env` และสร้าง secret preset

**ค่าที่ต้องการจาก User:**
- **ไฟล์ `.env`** ที่ root directory ต้องมีค่าต่อไปนี้:
  - `GIT_USER` - username สำหรับ Gitea admin
  - `GIT_PASSWORD` - password สำหรับ Gitea admin
  - `GRAFANA_USER` - username สำหรับ Grafana
  - `GRAFANA_PASSWORD` - password สำหรับ Grafana
  - ค่าอื่นๆ ที่ต้องการเก็บเป็น secret

**รูปแบบไฟล์ `.env`:**
```env
GIT_USER=admin
GIT_PASSWORD=your-secure-password
GRAFANA_USER=admin
GRAFANA_PASSWORD=your-secure-password
# เพิ่มค่าอื่นๆ ตามต้องการ
```

**คำสั่งที่รัน:**
```bash
./01-initial-secrets.bash
```

**หมายเหตุ:**
- Script จะรอจนกว่า Job `secret-init` จะสร้าง secret เสร็จ
- Secret จะถูกสร้างใน namespace `default` และ `gitea`

---

### 3. `02-initial-addons.bash`
**หน้าที่:**
- ติดตั้ง addons พื้นฐานสำหรับ cluster:
  - **ArgoCD** - GitOps deployment tool
  - **Ingress Controller** - จัดการ external access
  - **External Secrets** - จัดการ secrets จาก external sources
  - **Cert-Manager** - จัดการ SSL certificates
  - **Gitea** - Git repository server

**ค่าที่ต้องการจาก User:**
- ไม่มี (ใช้ config files ใน `00-configs/`)

**คำสั่งที่รัน:**
```bash
./02-initial-addons.bash
```

---

### 4. `03-install-monitoring.bash`
**หน้าที่:**
- ติดตั้ง monitoring stack:
  - **Prometheus** - metrics collection
  - **Grafana** - visualization dashboard
  - **AlertManager** - alert management
- ใช้ Helm chart `kube-prometheus-stack`

**ค่าที่ต้องการจาก User:**
- ไม่มี (ใช้ค่าจาก secrets ที่สร้างไว้แล้ว)
- แต่อาจต้องปรับแต่ง `prometheus-values.yaml` ตามความต้องการ

**คำสั่งที่รัน:**
```bash
./03-install-monitoring.bash
```

**หมายเหตุ:**
- Script จะรัน 2 รอบเพื่อให้แน่ใจว่า CRDs ถูกสร้างเสร็จ
- ต้องรันหลังจากติดตั้ง ArgoCD เสร็จแล้ว

---

### 5. `04-boot-strap.bash`
**หน้าที่:**
- Bootstrap ArgoCD applications
- ตั้งค่า ArgoCD ให้ sync กับ Git repositories
- สร้าง cluster secrets และ repository secrets
- รัน git-sync job เพื่อ sync code จาก remote

**ค่าที่ต้องการจาก User:**
- **MODE** (optional): `dev` หรือ `prod` (default: `prod`)
  - `dev` - ใช้ remote Git repository
  - `prod` - ใช้ local Gitea repository

**คำสั่งที่รัน:**
```bash
# Production mode (default)
./04-boot-strap.bash

# Development mode
./04-boot-strap.bash dev
```

**หมายเหตุ:**
- ใน dev mode จะแก้ไข `repoURL` ให้ชี้ไปที่ GitHub
- ใช้ค่า `GIT_USER` และ `GIT_PASSWORD` จาก secrets

---

## 🔑 สรุปค่าที่ต้องเตรียม

### ไฟล์ `.env` (จำเป็น)
สร้างไฟล์ `.env` ที่ root directory ของโปรเจกต์:

```env
# Gitea Admin Credentials
GIT_USER=admin
GIT_PASSWORD=your-gitea-password

# Grafana Admin Credentials
GRAFANA_USER=admin
GRAFANA_PASSWORD=your-grafana-password

# เพิ่มค่า secrets อื่นๆ ตามต้องการ
# ตัวอย่าง:
# DATABASE_URL=postgresql://user:pass@host:5432/db
# API_KEY=your-api-key
```

### Directories (จำเป็น)
- `/data` - สำหรับ K3s local storage (script จะสร้างให้)

### Optional Configurations
- แก้ไข `03-monitoring/prometheus-values.yaml` - ปรับแต่ง Prometheus/Grafana
- แก้ไข `03-monitoring/alm-config.yaml` - ตั้งค่า AlertManager
- แก้ไข files ใน `00-configs/` - ปรับแต่ง addons

---

## 🚀 ขั้นตอนการติดตั้งทั้งหมด

```bash
# 1. สร้างไฟล์ .env
cat > .env << 'EOF'
GIT_USER=admin
GIT_PASSWORD=your-secure-password
GRAFANA_USER=admin
GRAFANA_PASSWORD=your-secure-password
EOF

# 2. ติดตั้ง K3s
./00-install-k3s.bash

# 3. สร้าง initial secrets
./01-initial-secrets.bash

# 4. ติดตั้ง addons
./02-initial-addons.bash

# 5. รอให้ ArgoCD พร้อม (ประมาณ 2-3 นาที)
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

# 6. ติดตั้ง monitoring
./03-install-monitoring.bash

# 7. Bootstrap ArgoCD
./04-boot-strap.bash prod
```

---

## ⚠️ ข้อควรระวัง

1. **ต้องรัน scripts ตามลำดับ** - แต่ละ script ขึ้นอยู่กับ script ก่อนหน้า
2. **ไฟล์ `.env` ต้องมีก่อนรัน script ที่ 2** - มิเช่นนั้น secrets จะไม่ถูกสร้าง
3. **รอให้ pods พร้อมก่อนรัน script ถัดไป** - โดยเฉพาะ ArgoCD
4. **ใช้ password ที่ปลอดภัย** - อย่าใช้ password ง่ายๆ ใน production
5. **Backup ไฟล์ `.env`** - เก็บไว้ในที่ปลอดภัย ไม่ควร commit เข้า Git

---

## 📝 หมายเหตุเพิ่มเติม

- Scripts ใช้ `kubectl` และ `helm` ต้องติดตั้งไว้ก่อน
- ต้องมี `sudo` privileges สำหรับติดตั้ง K3s
- ใช้ Docker image จาก `asia-southeast1-docker.pkg.dev/its-artifact-commons/please-protect/please-protect-jobs:v0.0.14` สำหรับ secret initialization
- ArgoCD จะ sync applications จาก Git repositories (local Gitea หรือ remote GitHub)
