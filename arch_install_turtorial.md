# Arch Linux + Hyprland Installation Tutorial

<style>
code {
    background-color: #2d3748;
    color: #63b3ed;
    padding: 2px 6px;
    border-radius: 4px;
    font-family: 'Fira Code', 'Consolas', monospace;
    font-weight: 500;
    border: 1px solid #4a5568;
}

pre code {
    color: #e2e8f0;
    border: none;
    padding: 0;
}

blockquote {
    border-left: 4px solid #4299e1;
    padding: 12px 16px;
    margin: 16px 0;
    border-radius: 4px;
}

.warning {
    border-left-color: #f56565;
    background-color: #fed7d7;
}

.info {
    border-left-color: #48bb78;
    background-color: #c6f6d5;
}

h1, h2, h3 {
    color: #2482a7ff;
    border-bottom: 2px solid #e2e8f0;
    padding-bottom: 8px;
}

h1 {
    border-bottom-color: #4299e1;
}

h2 {
    border-bottom-color: #63b3ed;
    margin-top: 32px;
}

h3 {
    color: #FFFFFF;
    border-bottom-color: #90cdf4;
    margin-top: 24px;
}
</style>

**Author:** Vaman  
**Date:** 2025-03-20

> Dưới đây là hướng dẫn dual boot Arch Linux thủ công, sử dụng Hyprland trên ổ SSD rời, dành cho UEFI. Tôi viết file này với mục đích tìm hiểu về hệ điều hành, nên sẽ hơi dài.

---
## Mục lục

<div class="toc">

1. [**Chuẩn bị file ISO**](#1-chuẩn-bị-file-iso)
   - Tải file ISO từ trang chủ
   - Mount file ISO

2. [**Chuẩn bị ổ ssd rời và phân vùng**](#2-chuẩn-bị-ổ-ssd-rời-và-phân-vùng)
   - Sử dụng Disk Management
   - Sử dụng Command Line

3. [**Đưa dữ liệu vào phân vùng**](#3-đưa-dữ-liệu-vào-phân-vùng)

4. [**Đặt lại định dạng là EFI**](#4-đặt-lại-định-dạng-là-efi)
   - Cấu hình EFI System Partition
   - Xử lý lỗi GPT/MBR

5. [**Boot vào arch linux**](#5-boot-vào-arch-linux)
   - Cấu hình UEFI/BIOS
   - Tắt Secure Boot và Fast Boot

6. [**Cài đặt hệ điều hành**](#6-cài-đặt-hệ-điều-hành-mới-thông-qua-arch-vừa-boot-vào)
   - Xác định ổ SSD
   - Tạo bảng phân vùng
   - Format và Mount phân vùng

7. [**Cài Hệ Thống Cơ Bản**](#7-cài-hệ-thống-cơ-bản)
   - Base system installation
   - Tạo fstab
   - Chroot vào hệ thống

8. [**Cấu Hình Hệ Thống**](#8-cấu-hình-hệ-thống)
   - Thiết lập múi giờ
   - Cấu hình locale
   - Đặt hostname và password

9. [**Cài Đặt Bootloader**](#9-cài-đặt-bootloader-cho-hệ-thống-uefi)
   - Systemd-boot installation
   - Cấu hình boot entries

10. [**Tạo user**](#10-tạo-user)
    - Tạo tài khoản người dùng
    - Cấu hình sudo permissions

11. [**Hoàn Tất Cài Đặt**](#11-hoàn-tất-cài-đặt)
    - Cleanup và reboot

12. [**Cài Đặt và Cấu Hình Hyprland**](#12-cài-đặt-và-cấu-hình-hyprland)
    - Cài đặt Hyprland
    - Cấu hình terminal và launcher
    - Khởi động desktop environment

13. [**Tóm Tắt và Lưu Ý**](#13-tóm-tắt-và-lưu-ý)

</div>

---

## 1. Chuẩn bị file ISO

### Tải file ISO từ trang chủ của arch linux
- Click vào [đây](https://archlinux.org/download/).
- Kéo xuống dưới và chọn một phiên bản(ở đây mình chọn phiên bản đầu tiên `geo.mirror.pkgbuild.com` có thể chọn phiên bản khác).

### Mount file ISO
- Click vào chuột phải chọn `mount`.

---

## 2. Chuẩn bị ổ ssd rời và phân vùng

- Kiểm tra kích thước của ổ đĩa quang vừa xuất hiện.
    
    ví dụ: kích thước ổ quang của mình là `999MB`. Vậy thì mình sẽ tạo một phân vùng `1024MB`(1GB).
    
- Tạo một **Simple Volume** mới có kích thước **1024MB**, định dạng **FAT32** và gán nhãn **ISO**.

### Cách 1: Sử dụng Disk Management

1. **Ấn `Win + X`, Chọn `Disk Management`**
    
    Nếu có thông báo hỏi chọn `MBR` hay `GPT`, hãy chọn `GPT`

2. **Chọn ổ đĩa SSD rời**
    
    > ⚠️ **Lưu ý:** Chọn đúng ổ ssd rời.

3. **Tạo Simple Volume mới**
   - Tạo phân vùng mới với **1024MB**:
     
     Chuột phải vào vùng ổ đĩa đang trống chọn new simple volume
     
     Nhập kích thước `1024MB`
     
   - Chọn file system là FAT32
   - Nhập Volume label là ISO

![Disk Management](https://www.itechguides.com/wp-content/uploads/2024/04/Disk-Management-formats-a-USB-drive-with-the-NTFS-file-system-by-default.-If-you-wish-to-format-your-drive-with-the-FAT32-file-system-select-this-option-on-the-Format-Partition-page-of-the-wizard.webp)

**Hoàn tất tạo volume mới**

### Cách 2: Sử dụng Command Line

<details>
<summary>Chi tiết</summary>
Ngoài ra cũng có thể thực hiện những thao tác trên thông qua cmd:

1. **Mở cmd bằng quyền admin**

2. **Mở diskpart**
   ```bash
   diskpart
   ```

3. **Xem danh sách ổ cứng**
   ```bash
   list disk
   ```

4. **Chọn ổ đĩa**
   ```bash
   sel disk x
   ```
   x ở đây là số thứ tự ổ đĩa của bạn
   
   > ⚠️ **Lưu ý:** Chọn đúng ổ đĩa để tránh làm mất dữ liệu

5. **Tạo với kích thước là 1024MB**
   ```bash
   create partition primary size=1024
   ```

6. **Xem danh sách phân vùng**
   ```bash
   list part
   ```

7. **Chọn phân vùng vừa tạo**
   ```bash
   sel part x
   ```
   x ở đây là số thứ tự phân vùng của bạn
   
   > ⚠️ **Lưu ý:** Chọn đúng phân vùng để tránh làm mất dữ liệu

8. **Định dạng phân vùng thành FAT32 và đặt nhãn là ISO**
   ```bash
   format fs=fat32 label=ISO quick
   ```
    Có thể thay đổi nhãn theo ý muốn

9. **Đặt tên phân vùng là F**
   ```bash
   assign letter=F
   ```
    Có thể chọn letter khác

10. **Thoát diskpart**
    ```bash
    exit
    ```

</details>

> ⚠️ **Lưu ý:**
> - **Chọn đúng ổ đĩa (`sel disk`) để tránh mất dữ liệu!**
> - **Nếu chưa quen thao tác thì vẫ nên sử dụng `Disk Management` sẽ an toàn hơn**

---

## 3. Đưa dữ liệu vào phân vùng

- Mở ổ quang xuất hiện khi `mount` file ISO.
- `Copy` toàn bộ sau đó `paste` vào phân vùng mới tạo.
- Sau đó có thể eject ổ quang vừa mount bằng cách click chuột phải chọn eject.

---

## 4. Đặt lại định dạng là EFI

1. **Mở cmd bằng quyền admin**

2. **Mở diskpart**
   ```bash
   diskpart
   ```

3. **Xem danh sách ổ cứng**
   ```bash
   list disk
   ```

4. **Chọn ổ đĩa của**
   ```bash
   sel disk x
   ```
   x ở đây là số thứ tự ổ đĩa của bạn

5. **Xem danh sách phân vùng**
   ```bash
   list part
   ```

6. **Chọn phân vùng vừa copy paste ổ quang vào**
   ```bash
   sel part x
   ```
   x ở đây là số thứ tự phân vùng của bạn

7. **Gõ lệnh**
   ```bash
   help setid
   ```

8. **Tìm EFI System partition ID**
   - Kéo lên trên tìm dòng `EFI System partition:`
   - Sẽ thấy một dòng mã như này: `c12a7328-f81f-11d2-ba4b-00a0c93ec93b`
   - copy đoạn mã đó và gõ lệnh
   
   ```bash
   set id=<your_id>
   ```
   thay thế `<your_id>` bằng đoạn mã vừa lấy được 
   
   **Ví dụ:**
   ```bash
   set id=c12a7328-f81f-11d2-ba4b-00a0c93ec93b
   ```

9. **Xử lý lỗi (nếu có)**
   - Nếu thành công sẽ có thông báo
   - Trong trường hợp nếu gặp lỗi thì nên kiểm tra xem bảng phân vùng của có phải là gpt không hay là mbr bằng cách gõ lại lệnh
   
   ```bash
   list disk
   ```
   
   - Chú ý ổ cứng có phải là gpt không, nếu không thì hãy gõ lệnh
   
   ```bash
   convert gpt
   ```
   
   - Sau đó thực hiện lại.

---

## 5. Boot vào arch linux

> 💡 **Thông tin:** `BIOS` và `UEFI` đều là các loại `firmware`. Các máy tính hiện đại sử dụng `UEFI` thay thế cho `BIOS` nhờ tính năng tiên tiến và hiệu suất vượt trội hơn.

### Các bước thực hiện:

1. **Khởi động lại máy, và ấn phím `f2` để vào `UEFI`**
   - Với mỗi dòng máy thì sẽ khác, có thể là `f12`, `delete`, `esc`… 
   - Hãy search phím tắt vào `UEFI` của dòng máy đang sử dụng trước

   > ⚠️ **Lưu ý:** Hãy cẩn thận khi thao tác trong `UEFI` vì có thể gây lỗi nghiêm trọng tới máy. Chỉ nên thao tác với những cài đặt không gây nguy hiểm tới máy.

2. **Tắt `secure boot` và `fast boot`**
   - `Fast boot` và `secure boot` thường nằm trong mục `BOOT` và `SECURITY`

3. **Tạo `boot option` mới**
   - Đôi khi máy sẽ tự tạo thêm sau khi hoàn tất thao tác ở trên.

4. **Boot vào `arch linux`**
   - Chọn `arch linux` và `boot` vào.

---

## 6. Cài đặt hệ điều hành mới thông qua arch vừa boot vào

### 6.1. Xác định ổ SSD

Mở terminal và dùng lệnh:

```bash
lsblk -f
```

Xác định tên ổ (ví dụ: `/dev/sda`).

> ⚠️ **Lưu ý:** Hãy xác định đúng để tránh mất dữ liệu

### 6.2. Tạo bảng phân vùng

Dùng `cfdisk` để tạo bảng GPT trên ổ SSD:

```bash
cfdisk /dev/sda
```

#### Tạo phân vùng EFI (ESP): khoảng 300–512 MB, định dạng FAT32

Đây là phân vùng chứa các file khởi động và bootloader. UEFI sẽ tìm đến thư mục này và khởi động hệ thống.

- Trong giao diện cfdisk, Sẽ thấy nhiều phân vùng. Dùng phím mũi tên để di chuyển đến phân vùng trống.
- Chọn `New`.
- Chọn kích thước: Nhập kích thước cho phân vùng EFI, ở đây mình nhập: `512M` (512MB).
- Sau khi tạo xong, chọn phân vùng mới tạo (thường là `/dev/sda3`) và chọn `type`.
- Chọn định dạng `EFI System Partition`(EF00).

#### Tạo phân vùng root: phần còn lại (dạng ext4)

- Sau khi tạo phân vùng EFI, trong phân vùng trống còn lại, nhấn `New` để tạo thêm một phân vùng mới.
- Chọn kích thước: Có thể chọn toàn bộ không gian còn lại cho phân vùng root, bằng cách chọn toàn bộ hoặc nhập kích thước tùy ý.
- Phân vùng này sẽ được dùng làm phân vùng chứa hệ thống Arch Linux.
- Sau khi tạo xong, chọn phân vùng mới tạo (tạm gọi là `/dev/sda4` vì sda3 đã được dùng làm phân vùng EFI, hãy thay đổi tùy theo trường hợp) và chọn `type`.
- Chọn định dạng `linux system` (thường là mặc định không cần phải chọn).
- *(Tùy chọn)* Có thể tạo thêm phân vùng swap nếu cần.

### 6.3. Format phân vùng

#### EFI:
```bash
mkfs.fat -F32 /dev/sda3
```

#### Root:
```bash
mkfs.ext4 /dev/sda4
```

### 6.4. Mount các phân vùng

1. **Đảm bảo đang ở thư mục root**
   ```bash
   cd /
   ```

2. **Mount root vào `/mnt`:**
   ```bash
   mount /dev/sda4 /mnt
   ```

3. **Tạo thư mục `boot` trong `/mnt` và mount phân vùng EFI vào đấy:**
   ```bash
   mkdir /mnt/boot
   ```
   
   ```bash
   mount /dev/sda3 /mnt/boot
   ```


> 💡 **Giải thích bước "set id" ở bước số 4:**
> <details>
> <summary>Chi tiết</summary>
>
> Trước đó chúng ta đã dùng Diskpart để "set id" cho phân vùng. Việc này nhằm gán mã nhận diện (ID) cho phân vùng, giúp `BIOS/UEFI` nhận diện phân vùng đó là có khả năng boot (EFI System Partition). Nếu tạo phân vùng bằng Linux (vd: dùng `cfdisk`), ta sẽ đặt type là `EFI system partition` như bên trên, hai thao tác này tương tự nhau.
>
> </details>

---

## 7. Cài Hệ Thống Cơ Bản

### 7.1. Cài đặt base system

Sử dụng `pacstrap` để cài gói cơ bản:

```bash
pacstrap /mnt base linux linux-firmware
```

### 7.2. Tạo file fstab

```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

### 7.3. Chroot vào hệ thống mới cài

```bash
arch-chroot /mnt
```

> 💡 **Chroot:**
>
> <details>
>
> <summary>Chi tiết</summary>
>
> - Là một lệnh dùng để thay đổi thư mục root (/) của một tiến trình hoặc môi trường tạm thời.
> - Hiểu nôm na thì chroot giúp "thay đổi góc nhìn" của hệ thống, biến một thư mục nào đó trở thành thư mục root đối với các lệnh bên trong nó.
> - Điều này là cần thiết bởi vì arch hiện tại chúng ta đang dùng để cài đặt được gọi là phiên bản live (Arch live) được cấu hình sẵn dùng tạm thời để cài đặt một arch khác, có thể xóa arch live này sau khi hoàn tất cài đặt arch.
>
> </details>

---

## 8. Cấu Hình Hệ Thống

### 8.1. Thiết lập múi giờ

(Ở đây mình dùng múi giờ Việt Nam)

```bash
ln -sf /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime
```

```bash
hwclock --systohc
```

### 8.2. Cấu hình locale

1. **Mở file `/etc/locale.gen` và bỏ comment dòng:**
   ```
   en_US.UTF-8 UTF-8
   ```
   *(Hoặc nếu thích dùng locale Việt, hãy chọn vi_VN.UTF-8 nếu có NHƯNG ĐỪNG LÀM VẬY)*

2. **Sau đó chạy:**
   ```bash
   locale-gen
   ```

3. **Tạo file `/etc/locale.conf`:**
   ```bash
   echo "LANG=en_US.UTF-8" > /etc/locale.conf
   ```

### 8.3. Đặt hostname

1. **Dùng lệnh**
   ```bash
   echo "myarch" > /etc/hostname
   ```

2. **Mở file `/etc/hosts` bằng nano hoặc vim.**
   ```bash
   nano /etc/hosts
   ```

3. **Và chỉnh sửa file `/etc/hosts`:**
   ```
   127.0.0.1   localhost
   ::1         localhost
   127.0.1.1   myarch.localdomain myarch
   ```

### 8.4. Đặt mật khẩu cho root

```bash
passwd
```

- Sau đó nhập để tạo password mới

---

## 9. Cài Đặt Bootloader (cho hệ thống UEFI)

**Ở đây mình dùng systemd-boot**

### 9.1. Cài đặt systemd-boot

```bash
bootctl --path=/boot install
```

### 9.2. Tạo file loader

Tạo file `/boot/loader/loader.conf` với nội dung:

```
default arch.conf
timeout 3
editor 0
```

### 9.3. Kiểm tra PARTUUID của phân vùng root

```bash
blkid | grep sda4
```

- Chụp lại hoặc nhớ PARTUUID của phân vùng

> ⚠️ **Lưu ý:** Xác định đúng là PARTUUID chứ không phải UUID để tránh gặp lỗi. Có thể dùng UUID thay vì PARTUUID nhưng phải chính xác.

### 9.4. Tạo file boot entry

1. **Tạo file `/boot/loader/entries/arch.conf`:**
   ```bash
   nano /boot/loader/entries/arch.conf
   ```

2. **Điền nội dung như sau:**
   ```
   title   Arch Linux
   linux   /vmlinuz-linux
   initrd  /initramfs-linux.img
   options root=PARTUUID=<PARTUUID> rw
   ```
   
   thay `<PARTUUID>` bằng PARTUUID của phân vùng root mới lấy được ở trên

3. **Hoặc  cũng có thể dùng UUID**
   ```
   title   Arch Linux
   linux   /vmlinuz-linux
   initrd  /initramfs-linux.img
   options root=UUID=<UUID> rw
   ```

---

## 10. Tạo user

### 10.1. Tạo tài khoản người dùng thông thường

```bash
useradd -m -G wheel -s /bin/bash your_username
```

### 10.2. Tạo mật khẩu

```bash
passwd your_username
```

Sau đó tạo mật khẩu mới của người dùng

### 10.3. Cài đặt sudo

```bash
pacman -S sudo
```

```bash
EDITOR=nano visudo
```

- Trong file visudo, kiểm tra coi dòng sau có bị comment không, không thì xóa comment nếu chưa có thì hãy thêm mới:

```
%wheel ALL=(ALL:ALL) ALL
```

> 💡 Thao tác này để cấp quyền sử dụng sudo cho người dùng wheel

---

## 11. Hoàn Tất Cài Đặt

### 11.1. Thoát khỏi chroot

```bash
exit
```

### 11.2. Unmount phân vùng

```bash
umount -R /mnt
```

### 11.3. Khởi động lại hệ thống

```bash
reboot
```

- Vào `BIOS/UEFI`.
- Lúc này máy của sẽ xuất hiện một boot option mới. Có thể sẽ bị trùng tên với boot option để vào arch live.
- Boot vào option đấy
- Nếu thấy đang ở root mà không yêu cầu login, hãy nhập

```bash
su -
```

- Sau đó nhập tên người dùng và mật khẩu của để đăng nhập

---

## 12. Cài Đặt và Cấu Hình Hyprland

Sau khi boot vào hệ thống Arch mới, tiến hành cài Hyprland.

### 12.1. Cập nhật hệ thống

```bash
sudo pacman -Syu
```

### 12.2. Cài đặt Hyprland

Kiểm tra xem Hyprland có sẵn trong repo chính không:

```bash
sudo pacman -S hyprland wayland wlroots xorg-xwayland
```

Nếu chưa có (trường hợp cần cài từ AUR), có thể cài một AUR helper như `yay`:

```bash
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

Sau đó:

```bash
sudo yay -S hyprland wayland wlroots xorg-xwayland
```

### 12.3. Cài đặt một số ứng dụng hỗ trợ

Ví dụ: terminal emulator, launcher, panel, v.v.

```bash
sudo pacman -S alacritty wofi waybar
```

 có thể cài thêm các ứng dụng khác theo nhu cầu.

### 12.4. Cấu hình Hyprland

1. **Tạo thư mục cấu hình:**
   ```bash
   mkdir -p ~/.config/hypr
   ```

2. **Copy file cấu hình mẫu:**
   Nếu hệ thống đã cài file cấu hình mẫu (ví dụ: tại `/etc/xdg/hypr/hyprland.conf`), có thể copy về:
   
   ```bash
   cp /etc/xdg/hypr/hyprland.conf ~/.config/hypr/hyprland.conf
   ```
   
   Nếu không, có thể tự tạo file cấu hình.

3. **Chỉnh sửa cấu hình:**
   Mở file `~/.config/hypr/hyprland.conf` và thiết lập các keybinding, lệnh khởi chạy các ứng dụng…
   
   **Ví dụ:**
   ```
   # Khởi chạy terminal với Super+Enter
   bind = SUPER, Return, exec, alacritty
   # Đóng cửa sổ với Super+Q
   bind = SUPER, Q, killactive
   ```
   
   Có thể thêm các dòng `exec` để khởi động các tiện ích như wofi, waybar, hoặc các dịch vụ khác nếu cần.

   > 💡 Hãy tìm hiểu về hyprland trước khi cài đặt

### 12.5. Khởi động Hyprland

Đăng nhập và chạy lệnh:

```bash
Hyprland
```

---

## 13. Tóm Tắt và Lưu Ý

- **Lưu ý:** Cẩn thận khi thao tác với `bootloader`, `BIOS/UEFI` và ổ cứng vì có thể ảnh hưởng đến hệ điều hành còn lại bạn đang dùng.

- **Hệ thống tối giản:** Hướng dẫn trên cài đặt Arch Linux "tinh gọn" và sau đó cài Hyprland mà chưa cài đặt các công cụ cơ bản khác.

- **Cấu hình Hyprland:** Tùy chỉnh file cấu hình Hyprland theo nhu cầu (keybindings, theme, ứng dụng khởi chạy,…). Có thể tham khảo [wiki Hyprland](https://wiki.hyprland.org/) để biết thêm chi tiết.

---

Nếu có bất kỳ thắc mắc hay vấn đề nào trong quá trình cài, người này có thể hỗ trợ, liên hệ với hỗ trợ viên tại [đây](https://chatgpt.com/).