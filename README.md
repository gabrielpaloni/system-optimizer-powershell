# ⚡ System Optimizer: Automated Maintenance Tool

![Language](https://img.shields.io/badge/Language-PowerShell-5391FE?style=for-the-badge&logo=powershell&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Windows-0078D7?style=for-the-badge&logo=windows&logoColor=white)
![Status](https://img.shields.io/badge/Status-Completed-success?style=for-the-badge)

This repository hosts a **System Optimization Tool** developed to automate routine Windows maintenance. It represents a deep dive into **System Administration** and **GUI Development** using pure PowerShell, bridging the gap between backend scripting and frontend user experience.

<div align="center">
  <img width="4296" height="3032" alt="Image" src="https://github.com/user-attachments/assets/f819afee-89e8-482e-a805-c67e2693e32d" />
</div>

---

## 📘 Project Theme: Smart Maintenance

**Objective:**
To create a "set and forget" utility that monitors system health (via cooldown timers) and executes deep cleaning operations without user intervention, featuring a modern, borderless interface.

### 🎯 Key Features
* **Smart Scheduling:** Checks a local timestamp database (`ultima_limpeza.txt`) to ensure the script only runs once every **10 days**, avoiding unnecessary execution.
* **Modern GUI (WinForms):** A custom-built **borderless window** using .NET Framework within PowerShell, featuring symmetric design, dark mode, and hover effects.
* **Deep Cleaning:** Automates the removal of:
    * Recycle Bin contents.
    * Temp files (`%TEMP%`, `Prefetch`, `Windows\Temp`).
    * GPU Caches (NVIDIA/AMD/DirectX).
    * Windows Update leftovers (via `cleanmgr`).
* **Silent Elevation:** Automatically requests Admin privileges and runs `cleanmgr` in hidden mode for a seamless experience.

---

## 👥 Main Author

* **Gabriel Paloni** - *Developer & Engineer*

---

## 🛠️ Technical Evolution

This project was pivotal in mastering advanced Windows automation:
* **Interop:** Learned how to use **P/Invoke** (C# inside PowerShell) to manipulate Windows API (`user32.dll`) for window dragging without standard borders.
* **UX/UI in Code:** Transitioned from console-based scripts to full graphical interfaces using **System.Windows.Forms** purely via code.
* **Robustness:** Implemented `Try/Catch` blocks to handle locked system files gracefully, generating detailed **Logs** for auditing.

### Technologies Used
* **Scripting:** PowerShell 5.1+
* **Framework:** .NET (Windows Forms, System.Drawing)
* **Wrapper:** VBScript (for silent execution)
* **OS:** Windows 10/11

---

## 🚀 How to Run
1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/gabrielpaloni/system-optimizer.git](https://github.com/gabrielpaloni/system-optimizer.git)
    ```
2.  **Setup Environment:**
    * Create a folder `C:\ScriptLimpeza`.
    * Move `LimpezaPro.ps1` and `Executar.vbs` into it.
3.  **Run:**
    * Double-click `Executar.vbs` to test manually.
    * *(Optional)* Use the provided PowerShell snippet in the repo to add it to **Task Scheduler** for auto-start.

---

## 👨‍💻 Context
**Gabriel Paloni**
*Computer Science Student in Campinas, Brazil.*
While my academic focus is on **AI** and **Cybersecurity**, this project serves as a practical application of system hardening and automation—essential skills for any security professional.

---
<p align="center">
  <i>"Automation is cost cutting by tightening the corners and not cutting them."</i>
</p>
