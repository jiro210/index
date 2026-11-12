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
1. Vào `supabase.com/dashboard` → project **jff-finance**.
2. Menu trái → **SQL Editor** → **New query**.
3. Dán đoạn SQL → bấm **Run**.
4. Kiểm tra ở **Table Editor** xem bảng đã đúng chưa.

Bảng hiện tại của JFF là `jff_data`. Đoạn SQL tạo nó nằm trong `supabase_setup.sql` (đã chạy rồi, không cần chạy lại).

**Xem dữ liệu của mình:** Table Editor → `jff_data` → cột `data` là toàn bộ quỹ và lịch sử ở dạng JSON.

**Sao lưu dự phòng:** trong app vẫn có Menu ☰ → Nhập / Xuất File JSON. Nên tải một bản định kỳ.

---

## 4. Tài khoản (JFF tách riêng khỏi portfolio)

### Hiện trạng
- **JFF dùng project Supabase riêng: `jff-finance`** (địa chỉ `https://knhgzahoovwgaasmlanw.supabase.co`).
- **Portfolio vẫn dùng project `jiro-portfolio`.** Hai project có danh sách tài khoản hoàn toàn tách biệt, nên tài khoản tạo bên JFF (kể cả bằng Google) **không tồn tại và không đăng nhập được** bên portfolio.
- Bảng `jff_data` cũ trong `jiro-portfolio` không còn được app dùng. Sau khi chắc chắn dữ liệu đã sang project mới, có thể xóa bảng này (SQL Editor: `drop table public.jff_data;`). Đừng đụng các bảng `admins`, `site_settings`, `inquiries`.

### Tạo tài khoản và đăng nhập (không cần dịch vụ ngoài)
- Trong app: biểu tượng đám mây → tab **Tạo tài khoản** → nhập email, mật khẩu (từ 6 ký tự) → tạo xong thì đăng nhập.
- Mặc định Supabase bắt **xác nhận email**: app báo "đã gửi email xác nhận", bạn bấm liên kết trong thư rồi quay lại đăng nhập. Email gửi bằng dịch vụ mặc định của Supabase, giới hạn rất ít thư mỗi giờ, nên có thể chậm hoặc vào thư rác.
- Muốn đăng ký xong dùng được ngay, không cần email: Supabase → project **jff-finance** → **Authentication → Sign In / Providers → Email** → tắt **Confirm email** → Save.
- Cách khác không cần đăng ký: Authentication → Users → **Add user → Create new user** (tick *Auto Confirm User*).

### Chỉ mình bạn dùng?
- Ai biết địa chỉ web cũng có thể tạo tài khoản, nhưng mỗi người chỉ thấy dữ liệu của chính mình và **không liên quan gì tới portfolio**.
- Muốn khóa lại: sau khi bạn đã có tài khoản, vào **Authentication → Sign In / Providers** tắt **Allow new users to sign up**. Lúc đó nút Tạo tài khoản trong app sẽ báo lỗi, và bạn chỉ tạo thêm tài khoản bằng tay ở Authentication → Users.

## 5. Xử lý lỗi thường gặp

| Triệu chứng | Cách xử lý |
|---|---|
| Sửa xong web vẫn như cũ | Bấm Ctrl+F5; kiểm tra Vercel → Deployments xem bản mới đã READY chưa |
| Vercel báo ERROR | Bấm vào bản lỗi → xem Build Logs; hoặc rollback như mục 2 |
| "Sai email hoặc mật khẩu" | Kiểm tra user ở Authentication → Users của project **jff-finance** |
| "Chưa có bảng jff_data" | Chạy lại `supabase_setup.sql` trong SQL Editor |
| Biểu tượng đám mây màu vàng | Bấm vào xem thông báo; mất mạng thì tự thử lại khi có mạng |
| Máy khác hiện hộp "Dữ liệu 2 nơi khác nhau" | Chọn bản muốn giữ (thường là "Dùng dữ liệu đám mây") |

## 6. Điều tuyệt đối không làm
- Không đưa khóa `service_role` hoặc khóa `secret` lên GitHub hay dán vào app. Chỉ dùng khóa `anon` / `publishable`.
- Không xóa bảng `admins`, `site_settings`, `inquiries` (của portfolio).
