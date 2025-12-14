# 🎛️ Simple Web Shutdown

<div align="center">

[![Platform](https://img.shields.io/badge/Platform-Windows-blue?style=for-the-badge)](https://github.com/b4ho4/Simple-Web-Shutdown)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)
[![Developer](https://img.shields.io/badge/Dev-@b4ho4_-purple?style=for-the-badge)](https://instagram.com/b4ho4_)

**[🇺🇸 English](#-english)** | **[🇹🇷 Türkçe](#-türkçe)**

</div>

---

## 🇺🇸 English

**Control your Windows PC's power state from any phone or tablet using a secure, app-free web interface.**

This tool creates a lightweight, invisible web server on your PC using native PowerShell. It allows you to shutdown your computer remotely by visiting a local webpage on your phone.

> **Created by [@b4ho4_](https://instagram.com/b4ho4_)**

### 🌟 Features

* **No App Installation:** Works on Chrome, Safari, or any browser.
* **Ghost Mode:** Runs silently in the background (SYSTEM privileges).
* **Secure:** Protected by a PIN code (Default: `000`).
* **Modern UI:** Glassmorphism design with responsive mobile interface.
* **One-Click Setup:** Easy `.bat` installer.

### 🚀 Installation

1.  Download this repository (Code > Download ZIP).
2.  Extract the folder.
3.  Right-click on **`Install.bat`** and run it.
4.  Wait for the "INSTALLATION COMPLETE" message.
5.  **Restart your computer.**

The system will start automatically with Windows.

### 📱 How to Use

1.  Find your PC's Local IP Address (e.g., `192.168.1.100`).
2.  Open a browser on your phone (connected to the same Wi-Fi).
3.  Go to: `http://YOUR_PC_IP:8080`
4.  Enter PIN (Default: `000`) and tap **SHUTDOWN**.
5.  *Tip: Add the page to your Home Screen for an App-like experience.*

### ⚙️ Configuration

* **To Change PIN:** Open `Install.bat` with Notepad, find `$SecretPIN = "000"` and change it. Run the installer again.
* **To Uninstall:** Double-click `Uninstall.bat`. It will remove everything instantly.

### 🛡️ Security Note

This tool opens Port 8080 on your local network. It is designed for **LAN (Home Wi-Fi)** use only. Do not expose this port to the public internet without a VPN.

---

## 🇹🇷 Türkçe

**Bilgisayarınızı herhangi bir telefon veya tabletten, uygulama indirmeden kapatmanızı sağlayan modern bir araç.**

Bu proje, bilgisayarınızda (PowerShell kullanarak) görünmez ve hafif bir web sunucusu oluşturur. Telefonunuzdan bu yerel siteye girerek bilgisayarınızı tek tuşla kapatabilirsiniz.

> **Geliştirici: [@b4ho4_](https://instagram.com/b4ho4_)**

### 🌟 Özellikler

* **Uygulama Gerektirmez:** Chrome, Safari veya herhangi bir tarayıcıda çalışır.
* **Hayalet Modu:** Arka planda tamamen sessiz çalışır (SYSTEM yetkisiyle).
* **Güvenli:** PIN kodu korumalıdır (Varsayılan: `000`).
* **Modern Tasarım:** Buzlu cam (Glassmorphism) efektli şık arayüz.
* **Tek Tıkla Kurulum:** Basit `.bat` dosyası ile saniyeler içinde kurulur.

### 🚀 Kurulum

1.  Bu projeyi indirin (ZIP olarak).
2.  Klasörü masaüstüne çıkarın.
3.  **`Install.bat`** dosyasına sağ tıklayın ve çalıştırın.
4.  "INSTALLATION COMPLETE" yazısını bekleyin.
5.  **Bilgisayarınızı yeniden başlatın.**

Sistem, Windows açıldığında otomatik olarak devreye girecektir.

### 📱 Nasıl Kullanılır?

1.  Bilgisayarınızın Yerel IP Adresini öğrenin (Örn: `192.168.1.100`).
2.  Telefonunuzdan tarayıcıyı açın (Aynı Wi-Fi ağında olmalısınız).
3.  Adres çubuğuna şunu yazın: `http://BILGISAYAR_IP_ADRESINIZ:8080`
4.  PIN kodunu girin (Varsayılan: `000`) ve **SHUTDOWN** butonuna basın.
5.  *İpucu: Tarayıcıdan "Ana Ekrana Ekle" diyerek uygulama gibi kullanabilirsiniz.*

### ⚙️ Ayarlar

* **PIN Değiştirme:** `Install.bat` dosyasını Not Defteri ile açın, `$SecretPIN = "000"` satırını bulun ve istediğiniz şifreyi yazın. Dosyayı kaydedip tekrar çalıştırın.
* **Kaldırma (Silme):** `Uninstall.bat` dosyasına çift tıklayın. Her şeyi (görevleri, dosyaları, izinleri) anında siler.

### 🛡️ Güvenlik Notu

Bu araç yerel ağınızda (LAN) 8080 portunu kullanır. Sadece ev içi kullanım (Wi-Fi) içindir. VPN veya gerekli güvenlik önlemleri olmadan bu portu genel internete açmayın.

---

<div align="center">
  
Licensed under the MIT License <br>
Made with ❤️ by <b>b4ho4</b>

</div>
