# Hướng dẫn chi tiết: GitHub → Vercel → Supabase cho JFF

## 1. Hiểu đúng 3 thứ này làm gì

| Dịch vụ | Vai trò | Bạn chạm vào khi nào |
|---|---|---|
| **GitHub** | Nơi giữ code (`index.html`) | Khi muốn sửa app |
| **Vercel** | Tự lấy code từ GitHub và đưa lên mạng | Gần như không cần chạm, nó tự chạy |
| **Supabase** | Lưu **dữ liệu** (quỹ, lịch sử) và lo đăng nhập | Khi đổi cấu trúc bảng, tài khoản |

**Code không "đẩy lên Supabase".** Code đi GitHub → Vercel. Supabase chỉ chứa dữ liệu; app trên web tự nối với Supabase mỗi khi bạn đăng nhập. Sửa code không làm mất dữ liệu.

```
Sửa code → GitHub (main) → Vercel tự build (~1 phút) → Web cập nhật
                                         ↕ (khi bạn đăng nhập)
                                     Supabase (dữ liệu)
```

---

## 2. Cách đưa code mới từ GitHub lên web (làm mỗi lần sửa)

### Cách A — Sửa ngay trên trang GitHub (dễ nhất, không cần cài gì)
1. Vào `github.com/jiro210/index` → bấm file `index.html`.
2. Bấm biểu tượng **cây bút** (Edit this file) ở góc phải.
3. Sửa nội dung (dùng Ctrl+F để tìm đúng chỗ).
4. Bấm **Commit changes…** → ghi mô tả ngắn → chọn **Commit directly to the main branch** → **Commit changes**.
5. Chờ khoảng 1 phút, mở web, bấm **Ctrl+F5**. Xong.

### Cách B — An toàn hơn: sửa trên nhánh riêng rồi gộp
1. Trong repo, bấm ô chọn nhánh (đang ghi `main`) → gõ tên nhánh mới, ví dụ `sua-giao-dien` → **Create branch**.
2. Sửa file như Cách A nhưng commit vào nhánh mới đó.
3. Vercel tự tạo **bản xem thử** cho nhánh (xem ở Vercel → Deployments, dòng Preview). Mở thử xem ổn chưa.
4. Ổn thì vào GitHub → **Pull requests → New pull request** → chọn nhánh của bạn → **Create pull request** → **Merge pull request**.
5. Vercel tự đưa bản đó lên web chính.

> Nếu lỡ làm hỏng web: vào Vercel → project `index` → **Deployments** → chọn bản cũ chạy tốt → **⋯ → Promote to Production** (hoặc Instant Rollback). Web về lại ngay.

### Cách C — Nhờ Claude sửa
Gửi yêu cầu cho Claude kèm tên repo `jiro210/index`. Claude sẽ sửa, đẩy lên nhánh, kiểm tra Vercel rồi báo bạn.

---

## 3. Cách đổi cấu trúc dữ liệu trên Supabase (hiếm khi cần)

Chỉ cần khi thêm bảng hoặc cột mới.
1. Vào `supabase.com/dashboard` → project **jiro-portfolio**.
2. Menu trái → **SQL Editor** → **New query**.
3. Dán đoạn SQL → bấm **Run**.
4. Kiểm tra ở **Table Editor** xem bảng đã đúng chưa.

Bảng hiện tại của JFF là `jff_data`. Đoạn SQL tạo nó nằm trong `supabase_setup.sql` (đã chạy rồi, không cần chạy lại).

**Xem dữ liệu của mình:** Table Editor → `jff_data` → cột `data` là toàn bộ quỹ và lịch sử ở dạng JSON.

**Sao lưu dự phòng:** trong app vẫn có Menu ☰ → Nhập / Xuất File JSON. Nên tải một bản định kỳ.

---

## 4. Tài khoản: chỉ mình bạn đăng nhập

### Dùng chung project với portfolio có sao không?
- Hai app dùng chung **danh sách tài khoản** (Supabase Auth). Tức là một tài khoản đăng nhập được ở cả hai nơi.
- Nhưng **quyền thì tách riêng**:
  - Portfolio chỉ cho quản trị khi tài khoản nằm trong bảng `admins`. Một tài khoản không nằm trong `admins` thì dù đăng nhập được cũng **không đọc được `inquiries` và không sửa được `site_settings`**.
  - JFF chỉ cho mỗi tài khoản đọc và ghi đúng dòng dữ liệu của chính nó trong `jff_data`.
- Hiện trong project có đúng 1 tài khoản.

### Khóa không cho người lạ tạo tài khoản (nên làm)
Khóa Supabase nằm trong code là khóa công khai, nên nếu Supabase còn cho đăng ký thì về lý thuyết ai cũng gọi được API tạo tài khoản. App đã **gỡ nút "Tạo tài khoản"**, nhưng cần tắt luôn ở phía Supabase:

1. Supabase → project **jiro-portfolio** → **Authentication**.
2. Mục **Sign In / Providers** (hoặc **Providers → Email**).
3. Tắt công tắc **Allow new users to sign up**.
4. Bấm **Save**.

Từ đó chỉ tạo được tài khoản bằng tay: **Authentication → Users → Add user → Create new user** (tick *Auto Confirm User*).

Nên bật thêm: **Authentication → Sign In / Providers → Password → Leaked password protection**.

---

## 5. Xử lý lỗi thường gặp

| Triệu chứng | Cách xử lý |
|---|---|
| Sửa xong web vẫn như cũ | Bấm Ctrl+F5; kiểm tra Vercel → Deployments xem bản mới đã READY chưa |
| Vercel báo ERROR | Bấm vào bản lỗi → xem Build Logs; hoặc rollback như mục 2 |
| "Sai email hoặc mật khẩu" | Kiểm tra user ở Authentication → Users |
| "Chưa có bảng jff_data" | Chạy lại `supabase_setup.sql` trong SQL Editor |
| Biểu tượng đám mây màu vàng | Bấm vào xem thông báo; mất mạng thì tự thử lại khi có mạng |
| Máy khác hiện hộp "Dữ liệu 2 nơi khác nhau" | Chọn bản muốn giữ (thường là "Dùng dữ liệu đám mây") |

## 6. Điều tuyệt đối không làm
- Không đưa khóa `service_role` hoặc khóa `secret` lên GitHub hay dán vào app. Chỉ dùng khóa `anon` / `publishable`.
- Không xóa bảng `admins`, `site_settings`, `inquiries` (của portfolio).
