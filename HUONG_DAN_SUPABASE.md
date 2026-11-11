# Hướng dẫn: GitHub → Vercel → Supabase cho JFF

## Luồng hoạt động
- **GitHub** giữ code (`index.html`).
- **Vercel** tự build lại mỗi khi `main` có commit mới và đưa web lên mạng.
- **Supabase** chỉ lưu *dữ liệu* (quỹ, lịch sử) và lo đăng nhập. Code không "đưa lên Supabase", app trên Vercel tự kết nối Supabase khi bạn đăng nhập.

## Phần đã thiết lập sẵn
- Bảng `jff_data` trên project `jiro-portfolio`, bật bảo mật RLS: mỗi tài khoản chỉ đọc và ghi được dữ liệu của mình, người chưa đăng nhập không truy cập được.
- Project URL và publishable key đã điền sẵn trong `index.html`. Đây là khóa công khai, an toàn để nằm trong code.
- Code đã nằm ở nhánh `main`, Vercel đã build xong.

## Cách dùng lần đầu
1. Mở web (Ctrl+F5 hoặc cửa sổ ẩn danh để bỏ bản cũ trong bộ nhớ).
2. Bấm biểu tượng đám mây ở góc trên → **Đăng nhập**.
3. Dùng email và mật khẩu của tài khoản đã tạo trong Supabase (Authentication → Users).
4. Lần đầu, dữ liệu trên máy tự được đẩy lên đám mây. Biểu tượng đám mây màu xanh nghĩa là đã lưu.
5. Máy khác: đăng nhập cùng tài khoản, dữ liệu tự tải về. Nếu hai nơi khác nhau, app hỏi bạn giữ bản nào.

## Quy trình mỗi lần muốn sửa app
1. Sửa `index.html` (trên máy hoặc nhờ Claude).
2. Commit lên GitHub, nên làm trên nhánh riêng rồi mở Pull Request vào `main`.
3. Merge vào `main`, khoảng 1 phút sau Vercel cập nhật web. Dữ liệu trong Supabase không bị ảnh hưởng.

## Nếu có lỗi
| Triệu chứng | Cách xử lý |
|---|---|
| "Sai email hoặc mật khẩu" | Kiểm tra user trong Supabase → Authentication → Users, tick Auto Confirm |
| "Chưa có bảng jff_data" | Chạy `supabase_setup.sql` trong SQL Editor |
| Biểu tượng đám mây vàng | Bấm vào xem thông báo lỗi; mất mạng thì tự thử lại khi có mạng |
| Web vẫn là bản cũ | Ctrl+F5, hoặc xem Vercel → Deployments |

## Lưu ý bảo mật
- Chỉ dán khóa **anon / publishable** vào code. Khóa `service_role` hoặc `secret` tuyệt đối không đưa lên GitHub.
- Supabase đang cảnh báo nhẹ "Leaked password protection" chưa bật: vào Authentication → Sign In / Providers → Password để bật cho an toàn hơn.
- Project `jiro-portfolio` dùng chung cho web portfolio và app JFF. Hai bên dùng bảng riêng nên không lẫn dữ liệu.
