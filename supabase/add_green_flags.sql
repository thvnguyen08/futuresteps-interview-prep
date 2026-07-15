-- One-time migration: introduce a third content type — "green_flag" — for
-- every interview category. Green flags are the POSITIVE things an applicant
-- should show or do to make their case look strong and credible to an officer
-- (the counterpart to the existing "red_flag" warning signs).
--
-- Run this once in the Supabase SQL editor (Project → SQL Editor → New query).
--
-- ⚠  Run this file exactly once — the INSERTs would duplicate rows if run twice.

-- 1. Allow the new 'green_flag' value on the content_type discriminator.
alter table questions drop constraint if exists questions_content_type_check;
alter table questions add constraint questions_content_type_check
  check (content_type in ('question', 'red_flag', 'checklist', 'green_flag'));

-- 2. GREEN FLAGS. For each row, question_* names the strength to build/show and
--    answer_* explains why it helps and how to demonstrate it. Same table and
--    per-category tab as red flags / documents.
insert into questions (category, content_type, question_en, question_vi, answer_en, answer_vi) values

-- ── Marriage-based green card ─────────────────────────────────────────────
('marriage', 'green_flag', 'A shared financial life on paper', 'Đời sống tài chính chung được thể hiện trên giấy tờ',
 'Joint bank accounts, shared bills, and naming each other on insurance or beneficiaries are strong evidence of a real marriage. Build this over time and bring statements that show both names.',
 'Tài khoản ngân hàng chung, hóa đơn chung, và ghi tên nhau trên bảo hiểm hoặc người thụ hưởng là bằng chứng mạnh mẽ về một cuộc hôn nhân thật. Hãy xây dựng theo thời gian và mang theo sao kê thể hiện tên cả hai người.'),

('marriage', 'green_flag', 'Living together with proof of a shared address', 'Sống chung với bằng chứng cùng địa chỉ',
 'A lease or mortgage in both names, mail addressed to each of you at the same home, and shared utility bills show you truly live together. Officers weigh this heavily.',
 'Hợp đồng thuê nhà hoặc vay mua nhà đứng tên cả hai, thư từ gửi cho mỗi người tại cùng một nhà, và hóa đơn tiện ích chung cho thấy hai người thật sự sống chung. Viên chức rất coi trọng điều này.'),

('marriage', 'green_flag', 'Photos together across time and settings', 'Ảnh chụp cùng nhau qua nhiều thời điểm và hoàn cảnh',
 'Photos spread across months and years — trips, holidays, everyday moments, and time with each other''s families — tell the story of a genuine relationship far better than a few posed pictures.',
 'Ảnh trải dài qua nhiều tháng, nhiều năm — các chuyến đi, dịp lễ, khoảnh khắc đời thường, và thời gian bên gia đình của nhau — kể câu chuyện về một mối quan hệ thật tốt hơn nhiều so với vài tấm ảnh dàn dựng.'),

('marriage', 'green_flag', 'Both of you know each other''s daily routine', 'Cả hai đều nắm rõ sinh hoạt hằng ngày của nhau',
 'Knowing your spouse''s work schedule, what they eat, how they get around, and small daily habits shows you share a life. Review your real routines together, don''t memorize a script.',
 'Biết lịch làm việc của vợ/chồng, họ ăn gì, đi lại thế nào, và những thói quen nhỏ hằng ngày cho thấy hai người thật sự chung sống. Hãy cùng ôn lại thói quen thật, đừng học thuộc như đọc bài.'),

('marriage', 'green_flag', 'Family and friends know about the marriage', 'Gia đình và bạn bè biết về cuộc hôn nhân',
 'Wedding or gathering photos, messages from relatives, and affidavits from people who know you as a couple show the marriage is public and real, not hidden.',
 'Ảnh đám cưới hoặc tụ họp, tin nhắn từ người thân, và giấy xác nhận (affidavit) từ những người biết hai bạn là một cặp cho thấy cuộc hôn nhân là công khai và có thật, không giấu giếm.'),

('marriage', 'green_flag', 'A documented relationship timeline', 'Dòng thời gian quan hệ có bằng chứng',
 'Travel records, chat and call history, and photos that fill in how you met and stayed connected let you explain any long separations easily and consistently with your spouse.',
 'Hồ sơ đi lại, lịch sử tin nhắn và cuộc gọi, cùng ảnh chụp giúp làm rõ cách hai người quen nhau và giữ liên lạc, để bạn dễ dàng giải thích những lần xa cách dài một cách nhất quán với vợ/chồng.'),

-- ── Naturalization ────────────────────────────────────────────────────────
('naturalization', 'green_flag', 'Taxes filed for every required year', 'Đã khai thuế cho mọi năm bắt buộc',
 'Filing your federal and state taxes on time — and being on a payment plan if you owe — is central to good moral character. Bring tax transcripts or returns and any IRS payment-plan agreement.',
 'Khai thuế liên bang và tiểu bang đúng hạn — và có thỏa thuận trả góp nếu còn nợ — là điều cốt lõi cho tư cách đạo đức tốt. Hãy mang bản sao thuế (tax transcript) hoặc tờ khai và mọi thỏa thuận trả góp với IRS.'),

('naturalization', 'green_flag', 'Continuous residence with no long trips abroad', 'Cư trú liên tục, không có chuyến đi nước ngoài dài ngày',
 'Keeping trips outside the U.S. under six months protects your continuous residence. Bring a list of your trips (dates in and out) that matches your passport stamps.',
 'Giữ các chuyến đi ngoài Hoa Kỳ dưới sáu tháng giúp bảo vệ tình trạng cư trú liên tục của bạn. Hãy mang danh sách các chuyến đi (ngày xuất và nhập cảnh) khớp với dấu trong hộ chiếu.'),

('naturalization', 'green_flag', 'A clean record — or full honesty about any issue', 'Lý lịch trong sạch — hoặc hoàn toàn trung thực về mọi vấn đề',
 'No arrests is ideal, but if you have any citation, arrest, or charge, disclose it and bring certified court records showing the outcome. Hiding it is far worse than the issue itself.',
 'Không có tiền án là lý tưởng, nhưng nếu bạn từng bị phạt, bị bắt, hay bị buộc tội, hãy khai báo và mang hồ sơ tòa án có chứng thực cho thấy kết quả. Giấu giếm còn tệ hơn nhiều so với chính vấn đề đó.'),

('naturalization', 'green_flag', 'Selective Service registered (men who lived here 18–26)', 'Đã đăng ký Selective Service (nam giới sống tại đây từ 18–26 tuổi)',
 'Most men who were in the U.S. between ages 18 and 26 must have registered with Selective Service. Bring your registration confirmation; if you missed it, be ready to explain honestly.',
 'Hầu hết nam giới sống tại Hoa Kỳ trong độ tuổi 18 đến 26 phải đăng ký Selective Service. Hãy mang giấy xác nhận đăng ký; nếu bạn bỏ lỡ, hãy sẵn sàng giải thích một cách trung thực.'),

('naturalization', 'green_flag', 'Prepared for the civics and English tests', 'Chuẩn bị sẵn cho bài thi công dân và tiếng Anh',
 'Studying the civics questions and practicing reading, writing, and speaking English shows you''re ready. Confident, prepared answers make the whole interview go smoothly.',
 'Học các câu hỏi công dân và luyện đọc, viết, nói tiếng Anh cho thấy bạn đã sẵn sàng. Câu trả lời tự tin, có chuẩn bị giúp toàn bộ buổi phỏng vấn diễn ra suôn sẻ.'),

('naturalization', 'green_flag', 'Family and support obligations kept current', 'Nghĩa vụ gia đình và cấp dưỡng được thực hiện đầy đủ',
 'Paying court-ordered child support and other legal obligations supports good moral character. Bring proof of payment if this applies to you.',
 'Việc trả tiền cấp dưỡng con theo lệnh tòa và các nghĩa vụ pháp lý khác góp phần chứng minh tư cách đạo đức tốt. Hãy mang bằng chứng thanh toán nếu điều này áp dụng cho bạn.'),

-- ── Asylum ────────────────────────────────────────────────────────────────
('asylum', 'green_flag', 'Testimony that matches your I-589 declaration', 'Lời khai khớp với bản khai I-589',
 'Your spoken answers should line up with the written declaration you filed. Re-read your I-589 before the interview so your dates, names, and events stay consistent.',
 'Câu trả lời bằng lời của bạn nên khớp với bản khai đã nộp. Hãy đọc lại I-589 trước buổi phỏng vấn để ngày tháng, tên người, và các sự kiện luôn nhất quán.'),

('asylum', 'green_flag', 'A specific, detailed account of what happened', 'Trình bày cụ thể, chi tiết về những gì đã xảy ra',
 'Concrete details — dates, places, who did what — are more credible than general statements. Tell your real story clearly and tie it to a protected ground (race, religion, nationality, political opinion, or social group).',
 'Chi tiết cụ thể — ngày tháng, địa điểm, ai đã làm gì — đáng tin hơn những lời chung chung. Hãy kể câu chuyện thật của bạn một cách rõ ràng và gắn nó với một lý do được bảo vệ (chủng tộc, tôn giáo, quốc tịch, quan điểm chính trị, hoặc nhóm xã hội).'),

('asylum', 'green_flag', 'Evidence that backs up your claim', 'Bằng chứng chứng minh cho lời khai của bạn',
 'Medical or police records, threats, photos, witness affidavits, and news or country-condition reports corroborate your testimony. Organize them and bring certified English translations.',
 'Hồ sơ y tế hoặc cảnh sát, lời đe dọa, ảnh chụp, giấy xác nhận nhân chứng, và tin tức hoặc báo cáo tình hình đất nước sẽ củng cố lời khai của bạn. Hãy sắp xếp chúng và mang theo bản dịch tiếng Anh có chứng thực.'),

('asylum', 'green_flag', 'A consistent timeline you can explain', 'Một dòng thời gian nhất quán mà bạn có thể giải thích',
 'Keep your dates straight — when the harm happened, when you left, when you entered the U.S. A timeline that holds together across the interview builds credibility.',
 'Hãy nắm chắc các mốc thời gian — khi nào sự việc xảy ra, khi nào bạn rời đi, khi nào bạn vào Hoa Kỳ. Một dòng thời gian chặt chẽ xuyên suốt buổi phỏng vấn sẽ tạo được sự tin cậy.'),

('asylum', 'green_flag', 'Filing within one year of arrival', 'Nộp đơn trong vòng một năm kể từ khi đến',
 'Filing your asylum application within one year of arriving is expected. If you filed later, be ready to explain a valid exception (changed or extraordinary circumstances).',
 'Nộp đơn xin tị nạn trong vòng một năm kể từ khi đến là điều được mong đợi. Nếu bạn nộp muộn hơn, hãy sẵn sàng giải thích một ngoại lệ hợp lệ (hoàn cảnh thay đổi hoặc bất thường).'),

('asylum', 'green_flag', 'Honesty, including saying "I don''t remember"', 'Trung thực, kể cả khi nói "Tôi không nhớ"',
 'A calm, honest demeanor matters. If you genuinely don''t remember an exact date or detail, say so — that is more credible than guessing and contradicting your declaration.',
 'Thái độ bình tĩnh, trung thực rất quan trọng. Nếu bạn thật sự không nhớ một ngày hay chi tiết chính xác, hãy nói ra — điều đó đáng tin hơn là đoán bừa rồi mâu thuẫn với bản khai của bạn.'),

-- ── F-1 student visa ──────────────────────────────────────────────────────
('f1', 'green_flag', 'A clear study purpose tied to a career plan', 'Mục đích học tập rõ ràng, gắn với kế hoạch nghề nghiệp',
 'Explain why this specific program and school fit your goals and how the degree helps your career back home. A genuine, specific study plan is exactly what the officer wants to hear.',
 'Hãy giải thích vì sao chương trình và trường học cụ thể này phù hợp với mục tiêu của bạn và tấm bằng giúp ích cho sự nghiệp của bạn ở quê nhà như thế nào. Một kế hoạch học tập chân thật, cụ thể chính là điều viên chức muốn nghe.'),

('f1', 'green_flag', 'Strong ties to your home country', 'Mối ràng buộc chặt chẽ với quê hương',
 'Family, a job waiting, property, or a business at home show you intend to return after your studies. Return intent is the single biggest factor in an F-1 approval.',
 'Gia đình, một công việc đang chờ, tài sản, hoặc một cơ sở kinh doanh ở quê nhà cho thấy bạn có ý định trở về sau khi học xong. Ý định trở về là yếu tố quan trọng nhất để được cấp visa F-1.'),

('f1', 'green_flag', 'Clear, documented funding', 'Nguồn tài chính rõ ràng, có giấy tờ chứng minh',
 'Be ready to name your sponsor, their income, and show funds that cover tuition and living costs for the whole program. Be able to explain the source of any large recent deposits.',
 'Hãy sẵn sàng nêu tên người tài trợ, thu nhập của họ, và cho thấy nguồn tiền đủ trang trải học phí và sinh hoạt cho toàn bộ chương trình. Hãy có thể giải thích nguồn gốc của bất kỳ khoản tiền lớn nào mới gửi vào gần đây.'),

('f1', 'green_flag', 'Knowledge of your school and program', 'Hiểu biết về trường và chương trình học của bạn',
 'Knowing your school''s name, location, your major, and roughly what courses you''ll take shows the plan is real. Vague answers here raise doubt.',
 'Biết tên trường, địa điểm, ngành học, và đại khái những môn bạn sẽ học cho thấy kế hoạch là có thật. Câu trả lời mơ hồ ở phần này sẽ gây nghi ngờ.'),

('f1', 'green_flag', 'Answers consistent with your DS-160 and I-20', 'Câu trả lời nhất quán với DS-160 và I-20',
 'Your spoken answers should match what you wrote on your DS-160 and what''s on your I-20. Review both before the interview so nothing contradicts.',
 'Câu trả lời bằng lời của bạn nên khớp với những gì bạn đã ghi trên DS-160 và trên I-20. Hãy xem lại cả hai trước buổi phỏng vấn để không có gì mâu thuẫn.'),

-- ── B1/B2 visitor visa ────────────────────────────────────────────────────
('b1b2', 'green_flag', 'One clear purpose that matches your DS-160', 'Một mục đích rõ ràng khớp với DS-160',
 'Give a single, easy-to-verify reason for your trip — tourism, visiting family, or a short business trip — that matches your DS-160. One clear purpose beats several overlapping ones.',
 'Hãy nêu một lý do duy nhất, dễ kiểm chứng cho chuyến đi — du lịch, thăm gia đình, hoặc công tác ngắn ngày — khớp với DS-160 của bạn. Một mục đích rõ ràng tốt hơn nhiều lý do chồng chéo.'),

('b1b2', 'green_flag', 'Strong ties that bring you home', 'Những ràng buộc chắc chắn đưa bạn trở về',
 'A stable job, family, property, or a business at home are the strongest evidence you''ll return. Bring documents (employment letter, property or business papers) that prove them.',
 'Một công việc ổn định, gia đình, tài sản, hoặc một cơ sở kinh doanh ở quê nhà là bằng chứng mạnh nhất cho thấy bạn sẽ trở về. Hãy mang giấy tờ (thư xác nhận việc làm, giấy tờ nhà đất hoặc kinh doanh) để chứng minh.'),

('b1b2', 'green_flag', 'Proof you can pay for the trip', 'Bằng chứng bạn có thể chi trả cho chuyến đi',
 'Bank statements or a sponsor letter showing you can cover flights, lodging, and expenses reassure the officer you won''t work illegally or overstay.',
 'Sao kê ngân hàng hoặc thư bảo trợ cho thấy bạn có thể trang trải vé máy bay, chỗ ở, và chi phí sẽ giúp viên chức yên tâm rằng bạn sẽ không làm việc bất hợp pháp hay ở quá hạn.'),

('b1b2', 'green_flag', 'A defined trip with a return plan', 'Một chuyến đi có kế hoạch trở về rõ ràng',
 'Knowing roughly how long you''ll stay and when you''ll return — and having reasons to go back — shows this is a genuine short visit, not an attempt to immigrate.',
 'Biết đại khái bạn sẽ ở lại bao lâu và khi nào trở về — cùng những lý do để quay lại — cho thấy đây là một chuyến thăm ngắn thật sự, không phải ý định nhập cư.'),

('b1b2', 'green_flag', 'Honest, concise answers', 'Câu trả lời trung thực, ngắn gọn',
 'Answer only what''s asked, truthfully and briefly. Over-explaining or offering inconsistent details can create doubt where there was none.',
 'Chỉ trả lời đúng những gì được hỏi, một cách trung thực và ngắn gọn. Giải thích quá nhiều hoặc đưa ra các chi tiết không nhất quán có thể tạo ra nghi ngờ ở nơi vốn không có.');
