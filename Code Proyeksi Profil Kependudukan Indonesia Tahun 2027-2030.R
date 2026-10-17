
# PROYEKSI KEPENDUDUKAN INDONESIA METODE HAMILTON-PERRY (CCR) TAHUN 2027-2030
# Data Input: CSV Tahunan 2018 - 2026

install.packages("tidyverse")
install.packages("scales")

library(tidyverse)
library(scales)

setwd("C:/Users/Nicolas Evan/Desktop/Nico/Kuliah/Semester 7/Statistika Sosial dan Kependudukan/Data Jumlah Penduduk 2018-2026")
list.files()

# 1. Vektor 16 Kelompok Umur Resmi
kelompok_resmi <- c(
  "0-4", "5-9", "10-14", "15-19", "20-24", "25-29", 
  "30-34", "35-39", "40-44", "45-49", "50-54", "55-59", 
  "60-64", "65-69", "70-74", "75+"
)

tahun_historis <- 2018:2026

# 2. Fungsi Pembacaan Data CSV
baca_data_tahun <- function(thn) {
  nama_file <- paste0("Jumlah Penduduk Menurut Kelompok Umur dan Jenis Kelamin, ", thn, ".csv")
  
  df_raw <- read_csv(nama_file, show_col_types = FALSE)
  
  col_umur <- names(df_raw)[1]
  col_laki <- names(df_raw)[grep("laki", names(df_raw), ignore.case = TRUE)][1]
  col_puan <- names(df_raw)[grep("perempuan|wanita", names(df_raw), ignore.case = TRUE)][1]
  
  df_raw %>%
    select(
      Kelompok_Umur = all_of(col_umur),
      Laki_Laki     = all_of(col_laki),
      Perempuan     = all_of(col_puan)
    ) %>%
    mutate(
      Laki_Laki = as.numeric(Laki_Laki),
      Perempuan = as.numeric(Perempuan)
    ) %>%
    drop_na(Kelompok_Umur, Laki_Laki, Perempuan) %>%
    filter(Kelompok_Umur %in% kelompok_resmi) %>%
    distinct(Kelompok_Umur, .keep_all = TRUE) %>%
    mutate(
      Total = Laki_Laki + Perempuan,
      Tahun = thn
    )
}

# Gabungkan Data Historis (2018-2026)
data_historis <- map_dfr(tahun_historis, baca_data_tahun)

# 3. Estimasi Parameter Hamilton-Perry (CCR & CWR)
ccr_df <- data_historis %>%
  arrange(Kelompok_Umur, Tahun) %>%
  group_by(Kelompok_Umur) %>%
  mutate(
    CCR_Laki      = Laki_Laki / lag(Laki_Laki),
    CCR_Perempuan = Perempuan / lag(Perempuan)
  ) %>%
  filter(!is.na(CCR_Laki) & !is.nan(CCR_Laki) & !is.infinite(CCR_Laki)) %>%
  summarise(
    Mean_CCR_Laki      = exp(mean(log(CCR_Laki), na.rm = TRUE)),
    Mean_CCR_Perempuan = exp(mean(log(CCR_Perempuan), na.rm = TRUE)),
    .groups = "drop"
  )

kelompok_wus <- c("15-19", "20-24", "25-29", "30-34", "35-39", "40-44", "45-49")

cwr_df <- data_historis %>%
  group_by(Tahun) %>%
  summarise(
    Pop_0_4_Total = Total[Kelompok_Umur == "0-4"],
    Pop_0_4_Laki  = Laki_Laki[Kelompok_Umur == "0-4"],
    Pop_0_4_Puan  = Perempuan[Kelompok_Umur == "0-4"],
    WUS           = sum(Perempuan[Kelompok_Umur %in% kelompok_wus], na.rm = TRUE),
    CWR           = Pop_0_4_Total / WUS,
    Prop_Laki     = Pop_0_4_Laki / Pop_0_4_Total,
    Prop_Puan     = Pop_0_4_Puan / Pop_0_4_Total,
    .groups       = "drop"
  )

mean_cwr       <- mean(cwr_df$CWR, na.rm = TRUE)
mean_prop_laki <- mean(cwr_df$Prop_Laki, na.rm = TRUE)
mean_prop_puan <- mean(cwr_df$Prop_Puan, na.rm = TRUE)

# 4. Proyeksi Rekursif Hamilton-Perry (2027-2030)
tahun_proyeksi <- 2027:2030
list_proyeksi  <- list()
data_terakhir  <- data_historis %>% filter(Tahun == 2026)

for (thn in tahun_proyeksi) {
  proyeksi_next <- data_terakhir %>%
    left_join(ccr_df, by = "Kelompok_Umur") %>%
    mutate(
      Tahun     = thn,
      Laki_Laki = ifelse(Kelompok_Umur == "0-4", NA_real_, Laki_Laki * Mean_CCR_Laki),
      Perempuan = ifelse(Kelompok_Umur == "0-4", NA_real_, Perempuan * Mean_CCR_Perempuan)
    )
  
  wus_baru           <- sum(proyeksi_next$Perempuan[proyeksi_next$Kelompok_Umur %in% kelompok_wus], na.rm = TRUE)
  pop_0_4_total_baru <- mean_cwr * wus_baru
  
  proyeksi_next <- proyeksi_next %>%
    mutate(
      Laki_Laki = ifelse(Kelompok_Umur == "0-4", pop_0_4_total_baru * mean_prop_laki, Laki_Laki),
      Perempuan = ifelse(Kelompok_Umur == "0-4", pop_0_4_total_baru * mean_prop_puan, Perempuan),
      Total     = Laki_Laki + Perempuan
    ) %>%
    select(Kelompok_Umur, Laki_Laki, Perempuan, Total, Tahun)
  
  list_proyeksi[[as.character(thn)]] <- proyeksi_next
  data_terakhir <- proyeksi_next
}

data_proyeksi <- bind_rows(list_proyeksi)

data_full <- bind_rows(data_historis, data_proyeksi) %>%
  mutate(Kelompok_Umur = factor(Kelompok_Umur, levels = kelompok_resmi))


# 5. CETAK TABEL DI KONSOL R

# TABEL 1: Total Penduduk Indonesia per Tahun

tabel_1_total <- data_full %>%
  group_by(Tahun) %>%
  summarise(
    Laki_Laki_Juta = round(sum(Laki_Laki) / 1000, 3),
    Perempuan_Juta = round(sum(Perempuan) / 1000, 3),
    Total_Juta     = round(sum(Total) / 1000, 3),
    .groups        = "drop"
  ) %>%
  mutate(
    Status = ifelse(Tahun <= 2026, "Historis", "Proyeksi (CCR)")
  )

print(as.data.frame(tabel_1_total), row.names = FALSE)


# TABEL 2: Proporsi 3 Kelompok Usia Utama

tabel_2_prop <- data_full %>%
  mutate(
    Kategori_Usia = case_when(
      Kelompok_Umur %in% c("0-4", "5-9", "10-14") ~ "Usia_Muda_0_14",
      Kelompok_Umur %in% c("15-19", "20-24", "25-29", "30-34", "35-39", 
                           "40-44", "45-49", "50-54", "55-59", "60-64") ~ "Usia_Produktif_15_64",
      TRUE ~ "Lansia_65_Plus"
    )
  ) %>%
  group_by(Tahun, Kategori_Usia) %>%
  summarise(Total_Pop = sum(Total), .groups = "drop") %>%
  group_by(Tahun) %>%
  mutate(Persentase = round(Total_Pop / sum(Total_Pop) * 100, 2)) %>%
  select(-Total_Pop) %>%
  pivot_wider(names_from = Kategori_Usia, values_from = Persentase) %>%
  mutate(
    Status = ifelse(Tahun <= 2026, "Historis", "Proyeksi")
  ) %>%
  select(Tahun, Usia_Muda_0_14, Usia_Produktif_15_64, Lansia_65_Plus, Status)

print(as.data.frame(tabel_2_prop), row.names = FALSE)


# TABEL 3: Struktur Piramida Penduduk

tabel_3_piramida <- data_full %>%
  filter(Tahun %in% c(2018, 2026, 2030)) %>%
  select(Tahun, Kelompok_Umur, Laki_Laki, Perempuan, Total) %>%
  mutate(across(c(Laki_Laki, Perempuan, Total), ~ round(.x, 1))) %>%
  pivot_wider(
    names_from = Tahun,
    values_from = c(Laki_Laki, Perempuan, Total),
    names_glue = "{.value}_{Tahun}"
  )

print(as.data.frame(tabel_3_piramida), row.names = FALSE)


# 6. VISUALISASI 1: GRAFIK GARIS PREDIKSI HAMILTON-PERRY CCR

ringkasan_historis <- data_historis %>%
  group_by(Tahun) %>%
  summarise(Total = sum(Total), Jenis = "Historis", .groups = "drop")

ringkasan_proyeksi <- data_proyeksi %>%
  group_by(Tahun) %>%
  summarise(Total = sum(Total), Jenis = "Prediksi", .groups = "drop")

titik_sambung <- ringkasan_historis %>%
  filter(Tahun == 2026) %>%
  mutate(Jenis = "Prediksi")

ringkasan_gabungan <- bind_rows(ringkasan_historis, titik_sambung, ringkasan_proyeksi)

g1 <- ggplot(ringkasan_gabungan, aes(x = Tahun, y = Total / 1000, color = Jenis, linetype = Jenis)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2.5) +
  scale_color_manual(values = c("Historis" = "#1F77B4", "Prediksi" = "#E377C2")) +
  scale_linetype_manual(values = c("Historis" = "solid", "Prediksi" = "dashed")) +
  scale_x_continuous(breaks = 2018:2030) +
  scale_y_continuous(labels = comma) +
  labs(
    title = "Proyeksi Total Penduduk Indonesia (2027–2030)",
    subtitle = "Metode Hamilton-Perry Cohort Change Ratio (CCR)",
    x = "Tahun",
    y = "Jumlah Penduduk (Juta Jiwa)",
    color = "Kategori Data",
    linetype = "Kategori Data"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    panel.grid.minor = element_blank(),
    legend.position = "bottom"
  )

print(g1)


# 7. VISUALISASI 2: STACKED BAR CHART PROPORSI USIA UTAMA

data_kategori_usia <- data_full %>%
  mutate(
    Kategori_Usia = case_when(
      Kelompok_Umur %in% c("0-4", "5-9", "10-14") ~ "Usia Muda (0-14)",
      Kelompok_Umur %in% c("15-19", "20-24", "25-29", "30-34", "35-39", 
                           "40-44", "45-49", "50-54", "55-59", "60-64") ~ "Usia Produktif (15-64)",
      TRUE ~ "Lansia (65+)"
    )
  ) %>%
  group_by(Tahun, Kategori_Usia) %>%
  summarise(Total_Penduduk = sum(Total), .groups = "drop") %>%
  group_by(Tahun) %>%
  mutate(
    Persentase = Total_Penduduk / sum(Total_Penduduk) * 100
  ) %>%
  ungroup() %>%
  mutate(
    Kategori_Usia = factor(Kategori_Usia, levels = c("Usia Muda (0-14)", "Usia Produktif (15-64)", "Lansia (65+)"))
  )

g2_bar <- ggplot(data_kategori_usia, aes(x = factor(Tahun), y = Persentase, fill = Kategori_Usia)) +
  geom_col(width = 0.75, color = "white") +
  geom_vline(xintercept = 9.5, linetype = "dashed", color = "black", linewidth = 0.9) +
  scale_y_continuous(labels = function(x) paste0(x, "%"), limits = c(0, 100.1), expand = c(0, 0)) +
  scale_fill_manual(values = c(
    "Usia Muda (0-14)"       = "#1F77B4",
    "Usia Produktif (15-64)" = "#48CAE4",
    "Lansia (65+)"           = "#FFB703"
  )) +
  labs(
    title = "Proporsi Struktur Usia Penduduk Indonesia (2018–2030)",
    subtitle = "Data Historis (2018-2026) dan Proyeksi (2027-2030)",
    x = "Tahun",
    y = "Proporsi Terhadap Total Penduduk (%)",
    fill = "Kelompok Usia"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    panel.grid.minor = element_blank(),
    legend.position = "bottom"
  )

print(g2_bar)


# 8. VISUALISASI 3: PIRAMIDA PENDUDUK (KOMPARASI 2018, 2026, & 2030)

data_piramida <- data_full %>%
  filter(Tahun %in% c(2018, 2026, 2030)) %>%
  pivot_longer(
    cols = c("Laki_Laki", "Perempuan"),
    names_to = "Jenis_Kelamin",
    values_to = "Jumlah"
  ) %>%
  mutate(
    Jenis_Kelamin = ifelse(Jenis_Kelamin == "Laki_Laki", "Laki-Laki", "Perempuan"),
    Jumlah_Plot   = ifelse(Jenis_Kelamin == "Laki-Laki", -Jumlah / 1000, Jumlah / 1000),
    Tahun_Label   = paste0("Tahun ", Tahun, ifelse(Tahun == 2030, " (Proyeksi)", " (Historis)"))
  )

g3 <- ggplot(data_piramida, aes(x = Kelompok_Umur, y = Jumlah_Plot, fill = Jenis_Kelamin)) +
  geom_bar(stat = "identity", width = 0.8) +
  coord_flip() +
  facet_wrap(~ Tahun_Label) +
  scale_y_continuous(
    labels = function(x) comma(abs(x)),
    limits = max(abs(data_piramida$Jumlah_Plot)) * c(-1.1, 1.1)
  ) +
  scale_fill_manual(values = c("Laki-Laki" = "#2B5C8F", "Perempuan" = "#D95F02")) +
  labs(
    title = "Perbandingan Piramida Penduduk Indonesia",
    subtitle = "Perubahan Struktur Umur dan Jenis Kelamin (2018, 2026, dan Proyeksi 2030)",
    x = "Kelompok Umur",
    y = "Jumlah Penduduk (Juta Jiwa)",
    fill = "Jenis Kelamin"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    strip.text = element_text(face = "bold", size = 11)
  )

print(g3)
