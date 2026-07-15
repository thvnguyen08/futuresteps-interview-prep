-- One-time migration: add "red_flag" content for the Naturalization category.
-- Red flags are the common mistakes and warning signs that can delay or sink an
-- N-400 citizenship application. They appear under a "Red Flags" tab on the
-- Naturalization category, alongside the civics/English test.
--
-- Run this once in the Supabase SQL editor (Project → SQL Editor → New query).
--
-- ⚠  Run this file exactly once — the INSERTs would duplicate rows if run twice.
-- Note: the 'red_flag' content_type is already allowed by the constraint added
-- in add_marriage_expansion.sql, so no ALTER is needed here.

insert into questions (category, content_type, question_en, question_vi, answer_en, answer_vi) values

('naturalization', 'red_flag', 'Not filing taxes, or owing taxes with no payment plan', 'Không khai thuế, hoặc nợ thuế mà không có kế hoạch trả góp',
 'Unfiled or unpaid taxes are one of the most common reasons an N-400 is delayed or denied on good moral character. File any missing returns and set up an IRS payment plan before your interview, and bring proof.',
 'Không khai hoặc chưa nộp thuế là một trong những lý do phổ biến nhất khiến hồ sơ N-400 bị trì hoãn hoặc từ chối vì tư cách đạo đức. Hãy khai bù các tờ khai còn thiếu và lập thỏa thuận trả góp với IRS trước buổi phỏng vấn, và mang theo bằng chứng.'),

('naturalization', 'red_flag', 'Long trips abroad that break continuous residence', 'Những chuyến đi nước ngoài dài ngày làm gián đoạn cư trú liên tục',
 'A single trip of six months or more outside the U.S. can break your continuous residence and reset your eligibility clock. Be ready to explain any long trips, and bring evidence you kept your home, job, and ties in the U.S.',
 'Chỉ một chuyến đi từ sáu tháng trở lên ngoài Hoa Kỳ có thể làm gián đoạn cư trú liên tục và đặt lại thời gian đủ điều kiện của bạn. Hãy sẵn sàng giải thích mọi chuyến đi dài, và mang bằng chứng bạn vẫn giữ nhà ở, việc làm, và các ràng buộc tại Hoa Kỳ.'),

('naturalization', 'red_flag', 'Not disclosing arrests, citations, or charges', 'Không khai báo việc bị bắt, bị phạt, hay bị buộc tội',
 'Failing to disclose any arrest, citation, or charge — even a dismissed one — looks like dishonesty and can lead to denial. Disclose everything and bring certified court records showing the final outcome.',
 'Không khai báo bất kỳ lần bị bắt, bị phạt, hay bị buộc tội nào — kể cả vụ đã được bãi bỏ — trông giống như thiếu trung thực và có thể dẫn đến từ chối. Hãy khai báo mọi thứ và mang hồ sơ tòa án có chứng thực cho thấy kết quả cuối cùng.'),

('naturalization', 'red_flag', 'Men who never registered for Selective Service', 'Nam giới chưa bao giờ đăng ký Selective Service',
 'Most men who lived in the U.S. between ages 18 and 26 were required to register with Selective Service. Failing to register can raise a moral character question — bring your status information letter or a written explanation if you missed it.',
 'Hầu hết nam giới sống tại Hoa Kỳ trong độ tuổi 18 đến 26 phải đăng ký Selective Service. Việc không đăng ký có thể làm dấy lên câu hỏi về tư cách đạo đức — hãy mang thư thông tin tình trạng (status information letter) hoặc một lời giải thích bằng văn bản nếu bạn đã bỏ lỡ.'),

('naturalization', 'red_flag', 'Answers that don''t match your N-400 application', 'Câu trả lời không khớp với đơn N-400',
 'The officer goes through your N-400 line by line. Answers that contradict what you wrote — about trips, addresses, jobs, or marital history — create doubt. Re-read your full application before the interview.',
 'Viên chức sẽ xem xét đơn N-400 của bạn từng dòng một. Câu trả lời mâu thuẫn với những gì bạn đã ghi — về các chuyến đi, địa chỉ, công việc, hay lịch sử hôn nhân — sẽ gây nghi ngờ. Hãy đọc lại toàn bộ đơn trước buổi phỏng vấn.'),

('naturalization', 'red_flag', 'Owing overdue child support or alimony', 'Nợ tiền cấp dưỡng con hoặc cấp dưỡng vợ/chồng quá hạn',
 'Not paying court-ordered child support or alimony can be treated as a lack of good moral character. Get current or set up a payment arrangement, and bring proof of payments.',
 'Không trả tiền cấp dưỡng con hoặc cấp dưỡng vợ/chồng theo lệnh tòa có thể bị xem là thiếu tư cách đạo đức tốt. Hãy trả cho đầy đủ hoặc lập thỏa thuận thanh toán, và mang bằng chứng đã thanh toán.'),

('naturalization', 'red_flag', 'Claiming to be a U.S. citizen before you were one', 'Từng nhận là công dân Hoa Kỳ khi chưa phải',
 'Falsely claiming U.S. citizenship — to vote, get a job, or get a benefit — is a serious problem that can bar naturalization. If this may apply to you, get legal advice before filing rather than hiding it.',
 'Khai gian là công dân Hoa Kỳ — để bỏ phiếu, xin việc, hay hưởng phúc lợi — là một vấn đề nghiêm trọng có thể khiến bạn bị cấm nhập tịch. Nếu điều này có thể áp dụng cho bạn, hãy tìm tư vấn pháp lý trước khi nộp đơn thay vì giấu giếm.'),

('naturalization', 'red_flag', 'Registering to vote or voting before citizenship', 'Đăng ký bỏ phiếu hoặc bỏ phiếu trước khi có quốc tịch',
 'Voting in a federal election, or registering to vote, before you are a citizen can lead to denial and even removal. Be honest if it happened — often by mistake at a DMV — and seek legal advice.',
 'Bỏ phiếu trong một cuộc bầu cử liên bang, hoặc đăng ký bỏ phiếu, trước khi bạn là công dân có thể dẫn đến từ chối và thậm chí bị trục xuất. Hãy trung thực nếu điều đó đã xảy ra — thường là do nhầm lẫn tại DMV — và tìm tư vấn pháp lý.'),

('naturalization', 'red_flag', 'Failing to update USCIS with address changes', 'Không cập nhật thay đổi địa chỉ với USCIS',
 'Not reporting address changes can mean you miss your interview notice and can be held against you. Keep your address current with USCIS and bring your appointment notice to the interview.',
 'Không báo cáo thay đổi địa chỉ có thể khiến bạn bỏ lỡ giấy hẹn phỏng vấn và có thể bị xem xét bất lợi. Hãy giữ địa chỉ luôn cập nhật với USCIS và mang giấy hẹn đến buổi phỏng vấn.'),

('naturalization', 'red_flag', 'Guessing on civics answers instead of studying', 'Đoán bừa đáp án bài thi công dân thay vì học',
 'You must answer 6 of 10 civics questions correctly. Guessing instead of studying the official list risks failing a test you can easily pass with preparation. Practice the full question bank beforehand.',
 'Bạn phải trả lời đúng 6 trên 10 câu hỏi công dân. Đoán bừa thay vì học danh sách chính thức có nguy cơ trượt một bài thi mà bạn hoàn toàn có thể vượt qua nếu chuẩn bị. Hãy luyện tập toàn bộ ngân hàng câu hỏi từ trước.');
