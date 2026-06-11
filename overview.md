# PromptHub MVP

## Product Vision

PromptHub là ứng dụng mobile cho phép người dùng chia sẻ và khám phá các AI prompts.

Người dùng có thể:

* Xem ảnh AI được tạo bởi cộng đồng
* Xem prompt chính xác tạo ra ảnh
* Copy prompt
* Chia sẻ prompt
* Đăng prompt của riêng mình

Mục tiêu là tạo ra một thư viện prompt mở, đơn giản và dễ sử dụng.

---

# MVP Screens

## 1. Home Screen

Mục tiêu:

Khám phá prompts từ cộng đồng.

### Components

#### Search Bar

Tìm kiếm prompt.

#### Feed

Hiển thị dạng grid.

Mỗi item gồm:

* Preview Image
* Prompt Title
* Platform

Ví dụ:

* OpenAI
* Gemini
* Midjourney
* Flux
* Stable Diffusion

### Actions

* Open Prompt Detail
* Pull To Refresh
* Infinite Scroll

---

## 2. Prompt Detail Screen

Mục tiêu:

Xem và sử dụng prompt.

### Components

#### Preview Image

Ảnh AI kết quả.

#### Prompt Title

Ví dụ:

Astronaut In Flower Field

#### Platform

Ví dụ:

OpenAI GPT Image

#### Prompt

Hiển thị toàn bộ prompt.

### Actions

#### Copy Prompt

Sao chép prompt vào clipboard.

#### Share Prompt

Chia sẻ short link.

Ví dụ:

https://prompthub.onelink.me/AbCd

#### Edit Prompt

Chỉ hiện với chủ sở hữu.

---

## 3. Create Prompt Screen

Mục tiêu:

Đăng prompt mới.

### Fields

#### Preview Image

Upload ảnh kết quả.

#### Title

Ví dụ:

* Astronaut In Flower Field
* Anime Girl Portrait
* Product Photography

#### Platform

Dropdown.

Ví dụ:

* OpenAI
* Gemini
* Midjourney
* Flux
* Stable Diffusion

#### Prompt

Textarea.

Required.

### Actions

#### Publish Prompt

Tạo prompt mới.

---

## 4. Profile Screen

Mục tiêu:

Quản lý prompt cá nhân.

### Header

* Avatar
* Username

### My Prompts

Danh sách prompt đã đăng.

Hiển thị:

* Preview Image
* Title
* Platform

### Actions

* Open Prompt
* Edit Prompt
* Delete Prompt

---

## 5. Edit Prompt Screen

Mục tiêu:

Chỉnh sửa prompt đã đăng.

### Fields

* Preview Image
* Title
* Platform
* Prompt

### Actions

#### Save Changes

Lưu chỉnh sửa.

#### Delete Prompt

Xóa prompt.

---

# Navigation

Bottom Navigation

* Home
* Create
* Profile

---

# User Flow

## Explore Prompt

Open App

→ Home

→ Prompt Detail

→ Copy Prompt

→ Use Prompt

---

## Create Prompt

Open App

→ Create

→ Upload Image

→ Enter Prompt

→ Publish

---

## Edit Prompt

Open App

→ Profile

→ My Prompts

→ Edit Prompt

→ Save

---

# Sharing

## Short Link

Ví dụ:

https://prompthub.onelink.me/AbCd

### User Has App

Click Link

→ Open PromptHub

→ Open Prompt Detail

### User Doesn't Have App

Click Link

→ App Store / Google Play

→ Install App

→ Open Prompt Detail

---

# Database

## prompts

id

user_id

title

platform

prompt

image_url

share_url

created_at

updated_at

---

# Tech Stack

Frontend

* Flutter

Backend

* Supabase

Storage

* Supabase Storage

Authentication

* Anonymous Login

Deep Linking

* AppsFlyer OneLink

Analytics

* Firebase Analytics

Crash Reporting

* Firebase Crashlytics

---

# Positioning

Discover AI prompts and recreate stunning images instantly.
