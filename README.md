# Proyeksi Profil Kependudukan Indonesia Tahun 2027–2030

## 👤 Identitas Penulis
- **Nama:** Nicolas Evan
- **NPM:** 2306229626
- **Program Studi:** Statistika (Angkatan 2023)
- **Instansi:** Universitas Indonesia

---

## 📌 Deskripsi Proyek
Proyek ini bertujuan untuk memproyeksikan total populasi, proporsi kelompok usia, dan pergeseran struktur demografi Indonesia untuk periode **2027–2030** berdasarkan data historis runtut waktu **2018–2026**. Proyeksi ini mengimplementasikan **Metode Hamilton-Perry** sebagai alternatif pemodelan prospektif yang efisien untuk rentang jangka pendek hingga menengah tanpa memerlukan konstruksi tabel hayat terperinci. Hasil analisis ini memberikan gambaran kuantitatif mengenai keberlanjutan fenomena **bonus demografi** sekaligus awal transisi Indonesia menuju **masyarakat menua** (*ageing society*).

---

## 📊 Dataset & Cakupan Data
* **Sumber Data:** Data panel populasi Indonesia per kelompok umur 5 tahunan dan jenis kelamin (2018–2026).
* **Cakupan Kelompok Usia:** Kelompok umur 0–4 tahun hingga 75+ tahun (Laki-laki dan Perempuan).
* **Rentang Proyeksi:** Tahun 2027 hingga 2030 (4 tahun proyeksi).

---

## 🛠️ Alur Metodologi

```text
Data Historis (2018–2026) ➔ Penghitungan CCR & CWR ➔ Proyeksi Rekursif (2027–2030) ➔ Analisis Proporsi & Piramida
```

1. **Cohort Change Ratio (CCR):**
   - Memproyeksikan jumlah penduduk untuk kelompok umur 5–9 tahun hingga 75+ tahun secara rekursif berbasis pergeseran kohort historis.

2. **Child-Woman Ratio (CWR):**
   - Memproyeksikan kelompok umur balita (0–4 tahun) berdasarkan rasio terhadap jumlah wanita usia subur (15–49 tahun).

3. **Agregasi Indikator Demografi:**
   - Menghitung total populasi tahunan menurut jenis kelamin.
   - Menghitung proporsi tiga kelompok usia utama: Usia Muda (0–14 tahun), Usia Produktif (15–64 tahun), dan Lansia (65+ tahun).

4. **Visualisasi Piramida Penduduk:**
   - Memetakan pergeseran struktur umur dan jenis kelamin melalui komparasi piramida penduduk tahun 2018, 2026, dan proyeksi 2030.

---

## 📈 Hasil dan Temuan Utama

Model Hamilton-Perry memberikan estimasi dinamika kependudukan Indonesia hingga tahun 2030:

* **Total Penduduk:** Diproyeksikan meningkat dari **287,20 juta jiwa** pada tahun 2026 menjadi **302,50 juta jiwa** pada tahun 2030.
* **Usia Muda (0–14 Tahun):** Proporsi mengalami penurunan bertahap hingga **22,00%** pada tahun 2030 (turun dari 26,60% pada tahun 2018).
* **Usia Produktif (15–64 Tahun):** Proporsi bertahan stabil pada angka **68,86%** pada tahun 2030.
* **Usia Lansia (65+ Tahun):** Proporsi meningkat signifikan dari 5,81% (2018) menjadi **9,14%** pada tahun 2030.

---

## 🔍 Insight Utama (Demographic Dynamics)

* **Keberlanjutan Bonus Demografi:**
  Dominasi kelompok usia produktif yang stabil di kisaran 68,86% mengonfirmasi bahwa Indonesia masih berada dalam periode bonus demografi, memberikan peluang bagi pertumbuhan ekonomi dan ketersediaan tenaga kerja.

* **Awal Transisi Menuju Masyarakat Menua (*Ageing Society*):**
  Peningkatan proporsi lansia hingga melampaui ambang batas 7% (mencapai 9,14% pada tahun 2030) menandakan dimulainya transisi demografi menuju masyarakat menua. Hal ini memberikan acuan strategis bagi perencanaan jaminan sosial, penyediaan fasilitas kesehatan, dan layanan ramah lansia.
