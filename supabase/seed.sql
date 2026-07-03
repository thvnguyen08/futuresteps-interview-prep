-- Run this after schema.sql to populate a starter question bank.
-- For the "marriage", "asylum", and "f1" categories these are
-- personal-history/judgment questions, so the answer_* columns hold
-- coaching tips on how to answer well rather than a single fixed
-- answer. For "naturalization" the answer_* columns hold the official
-- civics answer.

insert into questions (category, question_en, question_vi, answer_en, answer_vi) values

-- ── Marriage-based green card (I-485) ──────────────────────────────
('marriage', 'How did you and your spouse meet?', 'Anh/chị và vợ/chồng đã gặp nhau như thế nào?',
 'Answer naturally and match the story in your application (Form I-130/I-485). Include when, where, and how you met — the officer is checking that both spouses tell a consistent story.',
 'Hãy trả lời tự nhiên và khớp với câu chuyện đã khai trong hồ sơ (Mẫu I-130/I-485). Nêu rõ thời gian, địa điểm và cách hai người gặp nhau — viên chức sẽ kiểm tra xem câu trả lời của hai vợ chồng có khớp nhau không.'),

('marriage', 'What was your first date like, and who else was there?', 'Buổi hẹn hò đầu tiên của anh/chị diễn ra như thế nào, và có ai khác đi cùng không?',
 'Be ready with specific details — restaurant name, activity, who paid, how you felt. Vague or contradictory answers between spouses are a major red flag to officers.',
 'Hãy chuẩn bị các chi tiết cụ thể — tên nhà hàng, hoạt động đã làm, ai là người trả tiền, cảm xúc lúc đó. Câu trả lời mơ hồ hoặc mâu thuẫn giữa hai vợ chồng là dấu hiệu đáng ngờ đối với viên chức.'),

('marriage', 'When and where did you get engaged or married?', 'Anh/chị đính hôn hoặc kết hôn khi nào và ở đâu?',
 'Know the exact date, city, and venue. If there was a proposal, be able to describe who proposed, how, and who was present.',
 'Cần nhớ chính xác ngày, thành phố và địa điểm tổ chức. Nếu có màn cầu hôn, hãy mô tả được ai là người cầu hôn, cầu hôn như thế nào và ai có mặt lúc đó.'),

('marriage', 'What is your spouse''s full name and date of birth?', 'Họ tên đầy đủ và ngày sinh của vợ/chồng anh/chị là gì?',
 'This should be automatic. Also know their place of birth, parents'' names, and any previous marriages — officers sometimes ask these as a quick consistency check.',
 'Câu này cần trả lời được ngay lập tức. Cũng nên nhớ nơi sinh, tên cha mẹ và các cuộc hôn nhân trước đây (nếu có) của vợ/chồng — viên chức đôi khi hỏi để kiểm tra nhanh độ chính xác.'),

('marriage', 'What is your current home address, and who else lives there?', 'Địa chỉ nhà hiện tại của anh/chị là gì, và còn ai khác sống ở đó?',
 'Officers verify shared residence carefully. Be able to describe the layout of your home — bedroom, kitchen, furniture — since this is hard to fake if you don''t actually live together.',
 'Viên chức kiểm tra rất kỹ việc hai vợ chồng có sống chung hay không. Hãy mô tả được bố cục căn nhà — phòng ngủ, nhà bếp, đồ nội thất — vì rất khó "diễn" nếu thực sự không sống chung.'),

('marriage', 'Who does the cooking, cleaning, and grocery shopping in your household?', 'Ai là người nấu ăn, dọn dẹp và đi chợ trong gia đình anh/chị?',
 'Describe your actual daily routine as a couple. Small, specific, everyday details (who takes out the trash, who does laundry) are more convincing than general statements.',
 'Hãy mô tả thói quen sinh hoạt thực tế hằng ngày của hai vợ chồng. Những chi tiết nhỏ, cụ thể (ai đổ rác, ai giặt đồ) sẽ thuyết phục hơn nhiều so với câu trả lời chung chung.'),

('marriage', 'Where does your spouse work, and what is their job?', 'Vợ/chồng anh/chị làm việc ở đâu và làm công việc gì?',
 'Know their employer''s name, job title, and rough work schedule. If they recently changed jobs, know why and when.',
 'Cần biết tên công ty, chức danh công việc và lịch làm việc đại khái của vợ/chồng. Nếu gần đây họ mới đổi việc, hãy biết lý do và thời điểm đổi việc.'),

('marriage', 'Do you have a joint bank account, joint lease, or other shared financial documents?', 'Anh/chị có tài khoản ngân hàng chung, hợp đồng thuê nhà chung hay giấy tờ tài chính chung nào khác không?',
 'This is core evidence of a bona fide marriage. Bring statements, the lease/mortgage, joint insurance, and utility bills in both names to your interview if you have them.',
 'Đây là bằng chứng cốt lõi cho một cuộc hôn nhân thật sự. Nếu có, hãy mang theo sao kê ngân hàng, hợp đồng thuê/mua nhà, bảo hiểm chung và hóa đơn tiện ích đứng tên cả hai người đến buổi phỏng vấn.'),

('marriage', 'Have you traveled together? Where, and when was your most recent trip?', 'Anh/chị đã từng đi du lịch cùng nhau chưa? Ở đâu, và chuyến đi gần nhất là khi nào?',
 'Photos, boarding passes, and hotel bookings help support your answer. Describe a specific trip with real details rather than a general summary.',
 'Hình ảnh, vé máy bay và đặt phòng khách sạn sẽ giúp củng cố câu trả lời. Hãy mô tả một chuyến đi cụ thể với chi tiết thật thay vì chỉ tóm tắt chung chung.'),

('marriage', 'Do you have children together? What are their names and ages?', 'Anh/chị có con chung không? Tên và tuổi của các con là gì?',
 'If you have children together, this is strong evidence of a genuine marriage — know their birthdates and be ready to describe daily family life with them.',
 'Nếu có con chung, đây là bằng chứng mạnh cho cuộc hôn nhân thật sự — cần nhớ ngày sinh của con và sẵn sàng mô tả cuộc sống gia đình hằng ngày cùng các con.'),

('marriage', 'How do you and your spouse typically celebrate birthdays or holidays together?', 'Anh/chị và vợ/chồng thường tổ chức sinh nhật hoặc các dịp lễ cùng nhau như thế nào?',
 'Give a real, recent example — a specific birthday, what you did, who was there. This shows shared life, not a rehearsed answer.',
 'Hãy đưa ra một ví dụ thật và gần đây — một dịp sinh nhật cụ thể, đã làm gì, có ai tham dự. Điều này cho thấy cuộc sống chung thật sự chứ không phải câu trả lời học thuộc.'),

('marriage', 'Has your relationship faced any challenges or disagreements? How did you handle them?', 'Mối quan hệ của anh/chị đã từng gặp khó khăn hay bất đồng nào chưa? Anh/chị đã giải quyết như thế nào?',
 'It''s normal and expected to say yes. Officers are wary of couples who claim a "perfect" relationship with zero disagreements — an honest, specific example is more credible.',
 'Việc trả lời "có" là hoàn toàn bình thường và được mong đợi. Viên chức thường nghi ngờ những cặp đôi khẳng định mối quan hệ "hoàn hảo" không hề có bất đồng — một ví dụ trung thực, cụ thể sẽ đáng tin hơn.'),

('marriage', 'Describe your wedding ceremony. Who attended, and how many guests were there?', 'Hãy mô tả lễ cưới của anh/chị. Ai đã tham dự, và có bao nhiêu khách mời?',
 'Know the venue, date, officiant, and roughly who was there (family, close friends). Photos and a guest list help, but be able to describe it in your own words, not just recite facts.',
 'Cần biết địa điểm, ngày tổ chức, người chủ trì hôn lễ, và những ai đã có mặt (gia đình, bạn bè thân). Hình ảnh và danh sách khách mời sẽ hữu ích, nhưng hãy mô tả bằng lời của chính mình chứ không chỉ đọc lại thông tin.'),

('marriage', 'How do you combine your finances — do you have a shared budget, and who pays which bills?', 'Anh/chị quản lý tài chính chung như thế nào — có ngân sách chung không, và ai trả những hóa đơn nào?',
 'Describe the actual arrangement, even if it''s informal (e.g., "I pay rent, she pays utilities"). Combined or clearly divided household finances support the bona fide marriage claim.',
 'Hãy mô tả cách sắp xếp thực tế, kể cả khi không chính thức (ví dụ: "tôi trả tiền thuê nhà, vợ tôi trả tiền điện nước"). Việc quản lý tài chính chung hoặc phân chia rõ ràng giúp củng cố bằng chứng hôn nhân thật sự.'),

('marriage', 'Is this a first marriage for you and your spouse? If not, how did your previous marriage end?', 'Đây có phải là cuộc hôn nhân đầu tiên của anh/chị và vợ/chồng không? Nếu không, cuộc hôn nhân trước đã kết thúc như thế nào?',
 'Be precise and consistent about prior marriages — divorce dates, death of a spouse, or annulment. Any prior marriage must be properly terminated before this one, and officers will check this carefully.',
 'Hãy trả lời chính xác và nhất quán về các cuộc hôn nhân trước đây — ngày ly hôn, vợ/chồng qua đời, hoặc hủy hôn. Cuộc hôn nhân trước phải được chấm dứt hợp pháp trước khi kết hôn lần này, và viên chức sẽ kiểm tra kỹ điều này.'),

('marriage', 'How often do you see or communicate with your spouse''s family? Have you met them in person?', 'Anh/chị gặp gỡ hoặc liên lạc với gia đình vợ/chồng thường xuyên như thế nào? Anh/chị đã gặp họ trực tiếp chưa?',
 'Genuine couples are usually integrated into each other''s families, at least to some degree. Describe specific visits, calls, or holidays spent with in-laws.',
 'Các cặp đôi thật sự thường có sự gắn kết với gia đình của nhau, ít nhiều. Hãy mô tả những lần thăm viếng, gọi điện, hoặc các dịp lễ đã dành thời gian cùng gia đình bên vợ/chồng.'),

('marriage', 'What are your plans as a couple for the next few years?', 'Kế hoạch của anh/chị với tư cách là một cặp vợ chồng trong vài năm tới là gì?',
 'Talk about real, shared plans — buying a home, having children, career moves, where you want to live. This shows a forward-looking, genuine partnership.',
 'Hãy chia sẻ những kế hoạch thật sự, có sự đồng thuận của cả hai — mua nhà, sinh con, thay đổi công việc, nơi muốn sinh sống. Điều này cho thấy một mối quan hệ đối tác thật sự và có định hướng tương lai.'),

('marriage', 'If you were interviewed separately, would your answers about your daily life match your spouse''s?', 'Nếu bị phỏng vấn riêng, câu trả lời của anh/chị về cuộc sống hằng ngày có khớp với câu trả lời của vợ/chồng không?',
 'This is exactly what officers test for in a Stokes interview (separate interviews for suspected fraud cases). Talk through your daily routines together beforehand so small details genuinely match.',
 'Đây chính là điều viên chức kiểm tra trong buổi phỏng vấn Stokes (phỏng vấn riêng khi nghi ngờ hôn nhân giả). Hãy cùng nhau ôn lại các thói quen sinh hoạt hằng ngày trước để các chi tiết nhỏ thật sự khớp nhau.'),

('marriage', 'Do you sponsor your spouse financially? What is your income, and do you have a joint sponsor if needed?', 'Anh/chị có bảo lãnh tài chính cho vợ/chồng không? Thu nhập của anh/chị là bao nhiêu, và có người đồng bảo lãnh (joint sponsor) nếu cần không?',
 'Know your income as stated on Form I-864 and whether it meets the poverty guideline for your household size. If you have a joint sponsor, know who they are and their relationship to you.',
 'Cần biết thu nhập đã khai trong Mẫu I-864 và liệu thu nhập đó có đạt mức yêu cầu theo hướng dẫn nghèo khó (poverty guideline) cho quy mô hộ gia đình hay không. Nếu có người đồng bảo lãnh, cần biết rõ họ là ai và mối quan hệ với anh/chị.'),

-- ── Naturalization (N-400) — official 2025 civics test (128 questions) ────
-- Source: USCIS Form M-1778 (09/25), "128 Civics Questions and Answers
-- (2025 version)" — https://www.uscis.gov/sites/default/files/document/
-- questions-and-answers/2025-Civics-Test-128-Questions-and-Answers.pdf
-- This is the test used for Form N-400 filed on or after October 20,
-- 2025 (128 possible questions, 20 asked at interview, 12 correct
-- needed to pass). It replaced the older 2008 test (100 questions,
-- 10 asked, 6 correct). Applicants who are 65+ with 20+ years as a
-- permanent resident may study only the 20 questions the USCIS PDF
-- marks with an asterisk. For questions whose answer changes with
-- elections/appointments (current President, VP, Governor, etc.) or
-- is specific to the applicant (their senator, representative, state),
-- the answer columns hold guidance rather than a fixed fact — always
-- confirm at uscis.gov/citizenship/testupdates before the interview.

-- AMERICAN GOVERNMENT — A: Principles of American Government
('naturalization', 'What is the form of government of the United States?', 'Hình thức chính quyền của Hoa Kỳ là gì?',
 'Republic; Constitution-based federal republic; representative democracy.',
 'Cộng hòa (Republic); cộng hòa liên bang dựa trên Hiến Pháp; dân chủ đại diện.'),

('naturalization', 'What is the supreme law of the land?', 'Luật tối cao của đất nước là gì?',
 'The Constitution.', 'Hiến Pháp (the Constitution).'),

('naturalization', 'Name one thing the U.S. Constitution does.', 'Hãy nêu một điều mà Hiến Pháp Hoa Kỳ thực hiện.',
 'Forms the government; defines powers of government; defines the parts of government; protects the rights of the people.',
 'Thiết lập chính phủ; xác định quyền hạn của chính phủ; xác định các bộ phận của chính phủ; bảo vệ quyền của người dân.'),

('naturalization', 'The U.S. Constitution starts with the words "We the People." What does "We the People" mean?', 'Hiến Pháp Hoa Kỳ bắt đầu bằng cụm từ "We the People" (Chúng ta, những người dân). Cụm từ này có nghĩa là gì?',
 'Self-government; popular sovereignty; consent of the governed; people should govern themselves; (example of) social contract.',
 'Chính quyền tự trị; chủ quyền thuộc về nhân dân; sự đồng thuận của người bị quản trị; người dân tự quản lý chính mình; một ví dụ về khế ước xã hội.'),

('naturalization', 'How are changes made to the U.S. Constitution?', 'Những thay đổi đối với Hiến Pháp Hoa Kỳ được thực hiện như thế nào?',
 'Amendments; the amendment process.', 'Tu chính án (amendments); quy trình tu chính.'),

('naturalization', 'What does the Bill of Rights protect?', 'Tuyên Ngôn Nhân Quyền (Bill of Rights) bảo vệ điều gì?',
 '(The basic) rights of Americans; (the basic) rights of people living in the United States.',
 'Các quyền cơ bản của người dân Mỹ; các quyền cơ bản của những người sống tại Hoa Kỳ.'),

('naturalization', 'How many amendments does the U.S. Constitution have?', 'Hiến Pháp Hoa Kỳ có tất cả bao nhiêu tu chính án?',
 'Twenty-seven (27).', 'Hai mươi bảy (27).'),

('naturalization', 'Why is the Declaration of Independence important?', 'Vì sao Bản Tuyên Ngôn Độc Lập lại quan trọng?',
 'It says America is free from British control; it says all people are created equal; it identifies inherent rights; it identifies individual freedoms.',
 'Nó tuyên bố nước Mỹ được tự do khỏi sự kiểm soát của Anh Quốc; nó khẳng định mọi người sinh ra đều bình đẳng; nó xác định các quyền vốn có; nó xác định các quyền tự do cá nhân.'),

('naturalization', 'What founding document said the American colonies were free from Britain?', 'Văn kiện lập quốc nào tuyên bố các thuộc địa Mỹ được tự do khỏi Anh Quốc?',
 'Declaration of Independence.', 'Bản Tuyên Ngôn Độc Lập (Declaration of Independence).'),

('naturalization', 'Name two important ideas from the Declaration of Independence and the U.S. Constitution.', 'Hãy nêu hai ý tưởng quan trọng từ Bản Tuyên Ngôn Độc Lập và Hiến Pháp Hoa Kỳ.',
 'Equality; liberty; social contract; natural rights; limited government; self-government.',
 'Bình đẳng; tự do; khế ước xã hội; quyền tự nhiên; chính phủ hữu hạn; chính quyền tự trị.'),

('naturalization', 'The words "Life, Liberty, and the pursuit of Happiness" are in what founding document?', 'Cụm từ "Life, Liberty, and the pursuit of Happiness" (Quyền sống, quyền tự do và quyền mưu cầu hạnh phúc) nằm trong văn kiện lập quốc nào?',
 'Declaration of Independence.', 'Bản Tuyên Ngôn Độc Lập (Declaration of Independence).'),

('naturalization', 'What is the economic system of the United States?', 'Hệ thống kinh tế của Hoa Kỳ là gì?',
 'Capitalism; free market economy.', 'Chủ nghĩa tư bản (capitalism); kinh tế thị trường tự do (free market economy).'),

('naturalization', 'What is the rule of law?', '"Rule of law" (pháp quyền) nghĩa là gì?',
 'Everyone must follow the law; leaders must obey the law; government must obey the law; no one is above the law.',
 'Mọi người đều phải tuân theo luật pháp; các nhà lãnh đạo phải tuân thủ luật pháp; chính phủ phải tuân thủ luật pháp; không ai đứng trên luật pháp.'),

('naturalization', 'Many documents influenced the U.S. Constitution. Name one.', 'Nhiều văn kiện đã ảnh hưởng đến Hiến Pháp Hoa Kỳ. Hãy nêu tên một văn kiện.',
 'Declaration of Independence; Articles of Confederation; Federalist Papers; Anti-Federalist Papers; Virginia Declaration of Rights; Fundamental Orders of Connecticut; Mayflower Compact; Iroquois Great Law of Peace.',
 'Bản Tuyên Ngôn Độc Lập; Các Điều Khoản Liên Bang (Articles of Confederation); Tập Luận Cương Người Liên Bang (Federalist Papers); Tập Luận Cương Chống Liên Bang (Anti-Federalist Papers); Tuyên Ngôn Nhân Quyền Virginia; Các Sắc Lệnh Cơ Bản Của Connecticut; Hiệp Ước Mayflower; Luật Hòa Bình Vĩ Đại Của Người Iroquois.'),

('naturalization', 'There are three branches of government. Why?', 'Chính phủ có ba nhánh. Vì sao?',
 'So one part does not become too powerful; checks and balances; separation of powers.',
 'Để không một nhánh nào trở nên quá quyền lực; cơ chế kiểm soát và cân bằng quyền lực; sự phân chia quyền lực.'),

-- AMERICAN GOVERNMENT — B: System of Government
('naturalization', 'Name the three branches of government.', 'Hãy nêu tên ba nhánh của chính phủ.',
 'Legislative, executive, and judicial; Congress, president, and the courts.',
 'Lập pháp, hành pháp và tư pháp; Quốc Hội, Tổng Thống và tòa án.'),

('naturalization', 'The President of the United States is in charge of which branch of government?', 'Tổng Thống Hoa Kỳ đứng đầu nhánh nào của chính phủ?',
 'Executive branch.', 'Nhánh hành pháp (executive branch).'),

('naturalization', 'What part of the federal government writes laws?', 'Bộ phận nào của chính phủ liên bang ban hành luật?',
 '(U.S.) Congress; (U.S. or national) legislature; legislative branch.',
 'Quốc Hội Hoa Kỳ; cơ quan lập pháp quốc gia; nhánh lập pháp.'),

('naturalization', 'What are the two parts of the U.S. Congress?', 'Quốc Hội Hoa Kỳ gồm hai phần nào?',
 'Senate and House of Representatives.', 'Thượng Viện (Senate) và Hạ Viện (House of Representatives).'),

('naturalization', 'Name one power of the U.S. Congress.', 'Hãy nêu một quyền hạn của Quốc Hội Hoa Kỳ.',
 'Writes laws; declares war; makes the federal budget.',
 'Ban hành luật; tuyên chiến; lập ngân sách liên bang.'),

('naturalization', 'How many U.S. senators are there?', 'Có tất cả bao nhiêu Thượng Nghị Sĩ Hoa Kỳ?',
 'One hundred (100).', 'Một trăm (100).'),

('naturalization', 'How long is a term for a U.S. senator?', 'Nhiệm kỳ của một Thượng Nghị Sĩ Hoa Kỳ kéo dài bao lâu?',
 'Six (6) years.', 'Sáu (6) năm.'),

('naturalization', 'Who is one of your state''s U.S. senators now?', 'Hãy nêu tên một trong các Thượng Nghị Sĩ Hoa Kỳ hiện tại của tiểu bang anh/chị.',
 'Answers vary by state — look up your state''s current U.S. Senators at senate.gov before your interview. (Residents of Washington, D.C. or a U.S. territory should answer that they have no U.S. senators.)',
 'Câu trả lời tùy theo tiểu bang — hãy tra cứu tên các Thượng Nghị Sĩ hiện tại của tiểu bang mình tại senate.gov trước buổi phỏng vấn. (Cư dân Washington, D.C. hoặc lãnh thổ Hoa Kỳ nên trả lời rằng nơi đó không có Thượng Nghị Sĩ.)'),

('naturalization', 'How many voting members are in the House of Representatives?', 'Hạ Viện có bao nhiêu thành viên có quyền biểu quyết?',
 'Four hundred thirty-five (435).', 'Bốn trăm ba mươi lăm (435).'),

('naturalization', 'How long is a term for a member of the House of Representatives?', 'Nhiệm kỳ của một Dân Biểu Hạ Viện kéo dài bao lâu?',
 'Two (2) years.', 'Hai (2) năm.'),

('naturalization', 'Why do U.S. representatives serve shorter terms than U.S. senators?', 'Vì sao Dân Biểu Hạ Viện có nhiệm kỳ ngắn hơn Thượng Nghị Sĩ?',
 'To more closely follow public opinion.', 'Để bám sát ý kiến công chúng hơn.'),

('naturalization', 'How many senators does each state have?', 'Mỗi tiểu bang có bao nhiêu Thượng Nghị Sĩ?',
 'Two (2).', 'Hai (2).'),

('naturalization', 'Why does each state have two senators?', 'Vì sao mỗi tiểu bang đều có hai Thượng Nghị Sĩ?',
 'Equal representation (for small states); the Great Compromise (Connecticut Compromise).',
 'Đại diện bình đẳng (cho các tiểu bang nhỏ); Thỏa Hiệp Lớn (Great Compromise, hay Thỏa Hiệp Connecticut).'),

('naturalization', 'Name your U.S. representative.', 'Hãy nêu tên Dân Biểu Hạ Viện của khu vực anh/chị.',
 'Answers vary by district — look up your current U.S. Representative at house.gov before your interview. (Residents of a territory with a nonvoting Delegate or Resident Commissioner may name that person, or state the territory has no voting representative.)',
 'Câu trả lời tùy theo khu vực bầu cử — hãy tra cứu tên Dân Biểu hiện tại của mình tại house.gov trước buổi phỏng vấn. (Cư dân lãnh thổ có Đại Biểu không bỏ phiếu có thể nêu tên người đó, hoặc trả lời rằng lãnh thổ không có Dân Biểu có quyền biểu quyết.)'),

('naturalization', 'What is the name of the Speaker of the House of Representatives now?', 'Ai là Chủ Tịch Hạ Viện hiện nay?',
 'Give the current Speaker''s name (check uscis.gov/citizenship/testupdates for the up-to-date official answer before your interview).',
 'Nêu tên Chủ Tịch Hạ Viện đương nhiệm (kiểm tra uscis.gov/citizenship/testupdates để có câu trả lời chính thức, cập nhật trước buổi phỏng vấn).'),

('naturalization', 'Who does a U.S. senator represent?', 'Một Thượng Nghị Sĩ Hoa Kỳ đại diện cho ai?',
 'Citizens of their state; people of their state.', 'Công dân của tiểu bang đó; người dân của tiểu bang đó.'),

('naturalization', 'Who elects U.S. senators?', 'Ai là người bầu ra Thượng Nghị Sĩ Hoa Kỳ?',
 'Citizens from their state.', 'Công dân của tiểu bang đó.'),

('naturalization', 'Who does a member of the House of Representatives represent?', 'Một Dân Biểu Hạ Viện đại diện cho ai?',
 'Citizens in their (congressional) district; people from their (congressional) district.',
 'Công dân trong khu vực bầu cử (congressional district) của họ; người dân trong khu vực bầu cử đó.'),

('naturalization', 'Who elects members of the House of Representatives?', 'Ai là người bầu ra các Dân Biểu Hạ Viện?',
 'Citizens from their (congressional) district.', 'Công dân trong khu vực bầu cử (congressional district) đó.'),

('naturalization', 'Some states have more representatives than other states. Why?', 'Một số tiểu bang có nhiều Dân Biểu Hạ Viện hơn các tiểu bang khác. Vì sao?',
 '(Because of) the state''s population; (because) they have more people; (because) some states have more people.',
 'Vì dân số của tiểu bang đó; vì tiểu bang đó có dân số đông hơn.'),

('naturalization', 'The President of the United States is elected for how many years?', 'Tổng Thống Hoa Kỳ được bầu cho nhiệm kỳ bao nhiêu năm?',
 'Four (4) years.', 'Bốn (4) năm.'),

('naturalization', 'The President of the United States can serve only two terms. Why?', 'Tổng Thống Hoa Kỳ chỉ có thể tại nhiệm tối đa hai nhiệm kỳ. Vì sao?',
 '(Because of) the 22nd Amendment; to keep the president from becoming too powerful.',
 'Vì Tu Chính Án Thứ 22 (22nd Amendment); để ngăn Tổng Thống trở nên quá quyền lực.'),

('naturalization', 'What is the name of the President of the United States now?', 'Tên của Tổng Thống Hoa Kỳ hiện nay là gì?',
 'Give the current President''s name (check uscis.gov/citizenship/testupdates for the up-to-date official answer before your interview).',
 'Nêu tên Tổng Thống đương nhiệm (kiểm tra uscis.gov/citizenship/testupdates để có câu trả lời chính thức, cập nhật trước buổi phỏng vấn).'),

('naturalization', 'What is the name of the Vice President of the United States now?', 'Tên của Phó Tổng Thống Hoa Kỳ hiện nay là gì?',
 'Give the current Vice President''s name (check uscis.gov/citizenship/testupdates for the up-to-date official answer before your interview).',
 'Nêu tên Phó Tổng Thống đương nhiệm (kiểm tra uscis.gov/citizenship/testupdates để có câu trả lời chính thức, cập nhật trước buổi phỏng vấn).'),

('naturalization', 'If the president can no longer serve, who becomes president?', 'Nếu Tổng Thống không thể tiếp tục tại nhiệm, ai sẽ trở thành Tổng Thống?',
 'The Vice President (of the United States).', 'Phó Tổng Thống Hoa Kỳ.'),

('naturalization', 'Name one power of the president.', 'Hãy nêu một quyền hạn của Tổng Thống.',
 'Signs bills into law; vetoes bills; enforces laws; Commander in Chief (of the military); chief diplomat; appoints federal judges.',
 'Ký ban hành dự luật thành luật; phủ quyết dự luật; thực thi luật pháp; Tổng Tư Lệnh quân đội; nhà ngoại giao trưởng; bổ nhiệm thẩm phán liên bang.'),

('naturalization', 'Who is Commander in Chief of the U.S. military?', 'Ai là Tổng Tư Lệnh quân đội Hoa Kỳ?',
 'The President (of the United States).', 'Tổng Thống Hoa Kỳ.'),

('naturalization', 'Who signs bills to become laws?', 'Ai là người ký ban hành dự luật để trở thành luật?',
 'The President (of the United States).', 'Tổng Thống Hoa Kỳ.'),

('naturalization', 'Who vetoes bills?', 'Ai là người có quyền phủ quyết (veto) dự luật?',
 'The President (of the United States).', 'Tổng Thống Hoa Kỳ.'),

('naturalization', 'Who appoints federal judges?', 'Ai là người bổ nhiệm thẩm phán liên bang?',
 'The President (of the United States).', 'Tổng Thống Hoa Kỳ.'),

('naturalization', 'The executive branch has many parts. Name one.', 'Nhánh hành pháp gồm nhiều bộ phận. Hãy nêu tên một bộ phận.',
 'President (of the United States); Cabinet; federal departments and agencies.',
 'Tổng Thống Hoa Kỳ; Nội Các (Cabinet); các bộ và cơ quan liên bang.'),

('naturalization', 'What does the President''s Cabinet do?', 'Nội Các của Tổng Thống có vai trò gì?',
 'Advises the President (of the United States).', 'Cố vấn cho Tổng Thống Hoa Kỳ.'),

('naturalization', 'What are two Cabinet-level positions?', 'Hãy nêu hai chức vụ cấp Nội Các.',
 'Attorney General; Secretary of Agriculture; Secretary of Commerce; Secretary of Education; Secretary of Energy; Secretary of Health and Human Services; Secretary of Homeland Security; Secretary of Housing and Urban Development; Secretary of the Interior; Secretary of Labor; Secretary of State; Secretary of Transportation; Secretary of the Treasury; Secretary of Veterans Affairs; Secretary of War (Defense); Vice President; or any other Cabinet-level position (e.g., Administrator of the EPA, Director of the CIA).',
 'Tổng Chưởng Lý (Attorney General); Bộ Trưởng Nông Nghiệp; Bộ Trưởng Thương Mại; Bộ Trưởng Giáo Dục; Bộ Trưởng Năng Lượng; Bộ Trưởng Y Tế và Dịch Vụ Nhân Sinh; Bộ Trưởng An Ninh Nội Địa; Bộ Trưởng Nhà Ở và Phát Triển Đô Thị; Bộ Trưởng Nội Vụ; Bộ Trưởng Lao Động; Bộ Trưởng Ngoại Giao; Bộ Trưởng Giao Thông; Bộ Trưởng Ngân Khố; Bộ Trưởng Cựu Chiến Binh; Bộ Trưởng Chiến Tranh (Quốc Phòng); Phó Tổng Thống; hoặc bất kỳ chức vụ cấp Nội Các nào khác.'),

('naturalization', 'Why is the Electoral College important?', 'Vì sao Đại Cử Tri Đoàn (Electoral College) lại quan trọng?',
 'It decides who is elected president; it provides a compromise between the popular election of the president and congressional selection.',
 'Đại Cử Tri Đoàn quyết định ai được bầu làm Tổng Thống; đây là một giải pháp thỏa hiệp giữa việc bầu Tổng Thống theo phiếu phổ thông và việc để Quốc Hội lựa chọn.'),

('naturalization', 'What is one part of the judicial branch?', 'Hãy nêu một bộ phận của nhánh tư pháp.',
 'Supreme Court; federal courts.', 'Tối Cao Pháp Viện (Supreme Court); các tòa án liên bang.'),

('naturalization', 'What does the judicial branch do?', 'Nhánh tư pháp có vai trò gì?',
 'Reviews laws; explains laws; resolves disputes (disagreements) about the law; decides if a law goes against the (U.S.) Constitution.',
 'Xem xét luật; giải thích luật; giải quyết tranh chấp (bất đồng) liên quan đến luật; quyết định xem một đạo luật có vi phạm Hiến Pháp hay không.'),

('naturalization', 'What is the highest court in the United States?', 'Tòa án cao nhất của Hoa Kỳ là gì?',
 'Supreme Court.', 'Tối Cao Pháp Viện (the Supreme Court).'),

('naturalization', 'How many seats are on the Supreme Court?', 'Tối Cao Pháp Viện có bao nhiêu ghế thẩm phán?',
 'Nine (9).', 'Chín (9).'),

('naturalization', 'How many Supreme Court justices are usually needed to decide a case?', 'Thông thường cần bao nhiêu thẩm phán Tối Cao Pháp Viện để quyết định một vụ án?',
 'Five (5).', 'Năm (5).'),

('naturalization', 'How long do Supreme Court justices serve?', 'Thẩm phán Tối Cao Pháp Viện tại nhiệm trong bao lâu?',
 '(For) life; lifetime appointment; (until) retirement.', 'Trọn đời; bổ nhiệm suốt đời; cho đến khi nghỉ hưu.'),

('naturalization', 'Supreme Court justices serve for life. Why?', 'Thẩm phán Tối Cao Pháp Viện tại nhiệm trọn đời. Vì sao?',
 'To be independent (of politics); to limit outside (political) influence.',
 'Để giữ tính độc lập (khỏi chính trị); để hạn chế ảnh hưởng (chính trị) từ bên ngoài.'),

('naturalization', 'Who is the Chief Justice of the United States now?', 'Ai là Chánh Án Tối Cao Pháp Viện Hoa Kỳ hiện nay?',
 'Give the current Chief Justice''s name (check uscis.gov/citizenship/testupdates for the up-to-date official answer before your interview).',
 'Nêu tên Chánh Án đương nhiệm (kiểm tra uscis.gov/citizenship/testupdates để có câu trả lời chính thức, cập nhật trước buổi phỏng vấn).'),

('naturalization', 'Name one power that is only for the federal government.', 'Hãy nêu một quyền lực chỉ thuộc về chính phủ liên bang.',
 'Print paper money; mint coins; declare war; create an army; make treaties; set foreign policy.',
 'In tiền giấy; đúc tiền xu; tuyên chiến; thành lập quân đội; ký kết hiệp ước; hoạch định chính sách đối ngoại.'),

('naturalization', 'Name one power that is only for the states.', 'Hãy nêu một quyền lực chỉ thuộc về các tiểu bang.',
 'Provide schooling and education; provide protection (police); provide safety (fire departments); give a driver''s license; approve zoning and land use.',
 'Cung cấp giáo dục; cung cấp lực lượng bảo vệ (cảnh sát); cung cấp an toàn (cứu hỏa); cấp bằng lái xe; phê duyệt quy hoạch và sử dụng đất.'),

('naturalization', 'What is the purpose of the 10th Amendment?', 'Mục đích của Tu Chính Án Thứ 10 (10th Amendment) là gì?',
 '(It states that the) powers not given to the federal government belong to the states or to the people.',
 'Quy định rằng những quyền lực không được giao cho chính phủ liên bang sẽ thuộc về các tiểu bang hoặc người dân.'),

('naturalization', 'Who is the governor of your state now?', 'Ai là Thống Đốc tiểu bang của anh/chị hiện nay?',
 'Answers vary by state — look up your current Governor before your interview. (D.C. residents should answer that D.C. does not have a governor.)',
 'Câu trả lời tùy theo tiểu bang — hãy tra cứu tên Thống Đốc hiện tại của tiểu bang mình trước buổi phỏng vấn. (Cư dân D.C. nên trả lời rằng D.C. không có Thống Đốc.)'),

('naturalization', 'What is the capital of your state?', 'Thủ phủ của tiểu bang anh/chị là gì?',
 'Answers vary by state — know your state capital. (D.C. residents should answer that D.C. is not a state and has no capital; territory residents should name their territory''s capital.)',
 'Câu trả lời tùy theo tiểu bang — hãy nhớ tên thủ phủ của tiểu bang mình. (Cư dân D.C. nên trả lời rằng D.C. không phải là tiểu bang nên không có thủ phủ; cư dân lãnh thổ nên nêu tên thủ phủ của lãnh thổ mình.)'),

-- AMERICAN GOVERNMENT — C: Rights and Responsibilities
('naturalization', 'There are four amendments to the U.S. Constitution about who can vote. Describe one of them.', 'Có bốn tu chính án của Hiến Pháp Hoa Kỳ quy định về quyền bầu cử. Hãy mô tả một trong số đó.',
 'Citizens eighteen (18) and older can vote; you don''t have to pay a poll tax to vote; any citizen can vote (women and men); a male citizen of any race can vote.',
 'Công dân từ 18 tuổi trở lên có quyền bầu cử; không phải đóng thuế bầu cử (poll tax) để đi bầu; mọi công dân đều có quyền bầu cử (cả nam và nữ); công dân nam thuộc bất kỳ chủng tộc nào đều có quyền bầu cử.'),

('naturalization', 'Who can vote in federal elections, run for federal office, and serve on a jury in the United States?', 'Ai được quyền bỏ phiếu trong bầu cử liên bang, ứng cử vào chức vụ liên bang, và tham gia bồi thẩm đoàn tại Hoa Kỳ?',
 'Citizens; citizens of the United States; U.S. citizens.', 'Công dân; công dân Hoa Kỳ.'),

('naturalization', 'What are three rights of everyone living in the United States?', 'Hãy nêu ba quyền mà bất kỳ ai sống tại Hoa Kỳ đều có.',
 'Freedom of expression; freedom of speech; freedom of assembly; freedom to petition the government; freedom of religion; the right to bear arms.',
 'Tự do bày tỏ quan điểm; tự do ngôn luận; tự do hội họp; quyền kiến nghị chính phủ; tự do tôn giáo; quyền sở hữu vũ khí.'),

('naturalization', 'What do we show loyalty to when we say the Pledge of Allegiance?', 'Khi đọc Lời Tuyên Thệ Trung Thành (Pledge of Allegiance), chúng ta thể hiện lòng trung thành với điều gì?',
 'The United States; the flag.', 'Hoa Kỳ; lá cờ Hoa Kỳ.'),

('naturalization', 'Name two promises that new citizens make in the Oath of Allegiance.', 'Hãy nêu hai lời tuyên thệ mà công dân mới tuyên thệ trong Lời Tuyên Thệ Trung Thành (Oath of Allegiance).',
 'Give up loyalty to other countries; defend the (U.S.) Constitution; obey the laws of the United States; serve in the military (if needed); serve (help, do important work for) the nation (if needed); be loyal to the United States.',
 'Từ bỏ trung thành với các quốc gia khác; bảo vệ Hiến Pháp Hoa Kỳ; tuân thủ luật pháp Hoa Kỳ; phục vụ trong quân đội (khi cần thiết); phục vụ (giúp đỡ, làm công việc quan trọng cho) đất nước (khi cần thiết); trung thành với Hoa Kỳ.'),

('naturalization', 'How can people become United States citizens?', 'Làm thế nào một người có thể trở thành công dân Hoa Kỳ?',
 'Be born in the United States, under the conditions set by the 14th Amendment; naturalize; derive citizenship (under conditions set by Congress).',
 'Sinh ra tại Hoa Kỳ, theo điều kiện quy định trong Tu Chính Án Thứ 14; nhập tịch (naturalize); có quốc tịch phái sinh (theo điều kiện do Quốc Hội quy định).'),

('naturalization', 'What are two examples of civic participation in the United States?', 'Hãy nêu hai ví dụ về sự tham gia dân sự tại Hoa Kỳ.',
 'Vote; run for office; join a political party; help with a campaign; join a civic group; join a community group; give an elected official your opinion; contact elected officials; support or oppose an issue or policy; write to a newspaper.',
 'Đi bầu cử; ứng cử; tham gia một đảng chính trị; giúp đỡ một chiến dịch tranh cử; tham gia một tổ chức dân sự; tham gia một tổ chức cộng đồng; nêu ý kiến với quan chức dân cử; liên hệ với quan chức dân cử; ủng hộ hoặc phản đối một vấn đề hay chính sách; viết thư cho báo chí.'),

('naturalization', 'What is one way Americans can serve their country?', 'Hãy nêu một cách người dân Mỹ có thể phục vụ đất nước.',
 'Vote; pay taxes; obey the law; serve in the military; run for office; work for local, state, or federal government.',
 'Đi bầu cử; đóng thuế; tuân thủ luật pháp; phục vụ trong quân đội; ứng cử; làm việc cho chính quyền địa phương, tiểu bang, hoặc liên bang.'),

('naturalization', 'Why is it important to pay federal taxes?', 'Vì sao việc đóng thuế liên bang lại quan trọng?',
 'Required by law; all people pay to fund the federal government; required by the (U.S.) Constitution (16th Amendment); civic duty.',
 'Được luật pháp yêu cầu; mọi người đóng thuế để cấp ngân sách cho chính phủ liên bang; được Hiến Pháp yêu cầu (Tu Chính Án Thứ 16); trách nhiệm công dân.'),

('naturalization', 'It is important for all men age 18 through 25 to register for the Selective Service. Name one reason why.', 'Việc tất cả nam giới từ 18 đến 25 tuổi đăng ký nghĩa vụ quân sự (Selective Service) là rất quan trọng. Hãy nêu một lý do vì sao.',
 'Required by law; civic duty; makes the draft fair, if needed.',
 'Được luật pháp yêu cầu; trách nhiệm công dân; giúp việc động viên quân sự (nếu cần) được công bằng.'),

-- AMERICAN HISTORY — A: Colonial Period and Independence
('naturalization', 'The colonists came to America for many reasons. Name one.', 'Những người thực dân đến Mỹ vì nhiều lý do. Hãy nêu một lý do.',
 'Freedom; political liberty; religious freedom; economic opportunity; escape persecution.',
 'Tự do; tự do chính trị; tự do tôn giáo; cơ hội kinh tế; thoát khỏi sự đàn áp.'),

('naturalization', 'Who lived in America before the Europeans arrived?', 'Ai đã sinh sống ở Mỹ trước khi người châu Âu đến?',
 'American Indians; Native Americans.', 'Người Da Đỏ Mỹ (American Indians); Người Bản Địa Mỹ (Native Americans).'),

('naturalization', 'What group of people was taken and sold as slaves?', 'Nhóm người nào đã bị bắt đi và bán làm nô lệ?',
 'Africans; people from Africa.', 'Người châu Phi (Africans).'),

('naturalization', 'What war did the Americans fight to win independence from Britain?', 'Người Mỹ đã chiến đấu trong cuộc chiến nào để giành độc lập từ Anh Quốc?',
 'American Revolution; the (American) Revolutionary War; War for (American) Independence.',
 'Cách Mạng Mỹ (American Revolution); Chiến Tranh Cách Mạng (Revolutionary War); Chiến Tranh Giành Độc Lập.'),

('naturalization', 'Name one reason why the Americans declared independence from Britain.', 'Hãy nêu một lý do khiến người Mỹ tuyên bố độc lập khỏi Anh Quốc.',
 'High taxes; taxation without representation; British soldiers stayed in Americans'' houses (boarding, quartering); they did not have self-government; Boston Massacre; Boston Tea Party (Tea Act); Stamp Act; Sugar Act; Townshend Acts; Intolerable (Coercive) Acts.',
 'Thuế cao; đánh thuế mà không có đại diện; quân lính Anh đóng quân trong nhà dân; họ không có quyền tự trị; Vụ Thảm Sát Boston; Tiệc Trà Boston (Đạo Luật Trà); Đạo Luật Tem; Đạo Luật Đường; Các Đạo Luật Townshend; Các Đạo Luật Không Thể Chấp Nhận.'),

('naturalization', 'Who wrote the Declaration of Independence?', 'Ai là người viết Bản Tuyên Ngôn Độc Lập?',
 '(Thomas) Jefferson.', '(Thomas) Jefferson.'),

('naturalization', 'When was the Declaration of Independence adopted?', 'Bản Tuyên Ngôn Độc Lập được thông qua vào ngày nào?',
 'July 4, 1776.', 'Ngày 4 tháng 7 năm 1776.'),

('naturalization', 'The American Revolution had many important events. Name one.', 'Cách Mạng Mỹ có nhiều sự kiện quan trọng. Hãy nêu tên một sự kiện.',
 '(Battle of) Bunker Hill; Declaration of Independence; Washington Crossing the Delaware (Battle of Trenton); (Battle of) Saratoga; Valley Forge (Encampment); (Battle of) Yorktown (British surrender at Yorktown).',
 'Trận Bunker Hill; Bản Tuyên Ngôn Độc Lập; Washington Vượt Sông Delaware (Trận Trenton); Trận Saratoga; Trại Đóng Quân Valley Forge; Trận Yorktown (quân Anh đầu hàng tại Yorktown).'),

('naturalization', 'There were 13 original states. Name five.', 'Có 13 tiểu bang ban đầu. Hãy nêu tên năm tiểu bang.',
 'New Hampshire, Massachusetts, Rhode Island, Connecticut, New York, New Jersey, Pennsylvania, Delaware, Maryland, Virginia, North Carolina, South Carolina, Georgia (name any five).',
 'New Hampshire, Massachusetts, Rhode Island, Connecticut, New York, New Jersey, Pennsylvania, Delaware, Maryland, Virginia, North Carolina, South Carolina, Georgia (nêu tên bất kỳ năm tiểu bang nào).'),

('naturalization', 'What founding document was written in 1787?', 'Văn kiện lập quốc nào được viết vào năm 1787?',
 '(U.S.) Constitution.', 'Hiến Pháp Hoa Kỳ.'),

('naturalization', 'The Federalist Papers supported the passage of the U.S. Constitution. Name one of the writers.', 'Tập Luận Cương Người Liên Bang (The Federalist Papers) đã ủng hộ việc thông qua Hiến Pháp Hoa Kỳ. Hãy nêu tên một trong những tác giả.',
 '(James) Madison; (Alexander) Hamilton; (John) Jay; Publius.',
 '(James) Madison; (Alexander) Hamilton; (John) Jay; Publius.'),

('naturalization', 'Why were the Federalist Papers important?', 'Vì sao Tập Luận Cương Người Liên Bang lại quan trọng?',
 'They helped people understand the (U.S.) Constitution; they supported passing the (U.S.) Constitution.',
 'Giúp người dân hiểu rõ Hiến Pháp Hoa Kỳ; ủng hộ việc thông qua Hiến Pháp Hoa Kỳ.'),

('naturalization', 'Benjamin Franklin is famous for many things. Name one.', 'Benjamin Franklin nổi tiếng với nhiều điều. Hãy nêu tên một điều.',
 'Founded the first free public libraries; first Postmaster General of the United States; helped write the Declaration of Independence; inventor; U.S. diplomat.',
 'Sáng lập các thư viện công cộng miễn phí đầu tiên; Tổng Cục Trưởng Bưu Điện đầu tiên của Hoa Kỳ; góp phần soạn thảo Bản Tuyên Ngôn Độc Lập; nhà phát minh; nhà ngoại giao Hoa Kỳ.'),

('naturalization', 'George Washington is famous for many things. Name one.', 'George Washington nổi tiếng với nhiều điều. Hãy nêu tên một điều.',
 '"Father of Our Country"; first president of the United States; general of the Continental Army; president of the Constitutional Convention.',
 '"Cha Đẻ Của Đất Nước Chúng Ta"; Tổng Thống đầu tiên của Hoa Kỳ; Đại Tướng Lục Quân Lục Địa (Continental Army); Chủ Tịch Hội Nghị Lập Hiến.'),

('naturalization', 'Thomas Jefferson is famous for many things. Name one.', 'Thomas Jefferson nổi tiếng với nhiều điều. Hãy nêu tên một điều.',
 'Writer of the Declaration of Independence; third president of the United States; doubled the size of the United States (Louisiana Purchase); first Secretary of State; founded the University of Virginia; writer of the Virginia Statute on Religious Freedom.',
 'Tác giả Bản Tuyên Ngôn Độc Lập; Tổng Thống thứ ba của Hoa Kỳ; tăng gấp đôi diện tích Hoa Kỳ (Thương Vụ Louisiana); Bộ Trưởng Ngoại Giao đầu tiên; sáng lập Đại Học Virginia; tác giả Đạo Luật Tự Do Tôn Giáo Virginia.'),

('naturalization', 'James Madison is famous for many things. Name one.', 'James Madison nổi tiếng với nhiều điều. Hãy nêu tên một điều.',
 '"Father of the Constitution"; fourth president of the United States; president during the War of 1812; one of the writers of the Federalist Papers.',
 '"Cha Đẻ Của Hiến Pháp"; Tổng Thống thứ tư của Hoa Kỳ; Tổng Thống trong Chiến Tranh Năm 1812; một trong các tác giả của Tập Luận Cương Người Liên Bang.'),

('naturalization', 'Alexander Hamilton is famous for many things. Name one.', 'Alexander Hamilton nổi tiếng với nhiều điều. Hãy nêu tên một điều.',
 'First Secretary of the Treasury; one of the writers of the Federalist Papers; helped establish the First Bank of the United States; aide to General George Washington; member of the Continental Congress.',
 'Bộ Trưởng Ngân Khố đầu tiên; một trong các tác giả của Tập Luận Cương Người Liên Bang; góp phần thành lập Ngân Hàng Đầu Tiên của Hoa Kỳ; phụ tá của Đại Tướng George Washington; thành viên Quốc Hội Lục Địa.'),

-- AMERICAN HISTORY — B: 1800s
('naturalization', 'What territory did the United States buy from France in 1803?', 'Hoa Kỳ đã mua vùng lãnh thổ nào từ Pháp vào năm 1803?',
 'Louisiana Territory; Louisiana.', 'Lãnh Thổ Louisiana (the Louisiana Territory).'),

('naturalization', 'Name one war fought by the United States in the 1800s.', 'Hãy nêu tên một cuộc chiến mà Hoa Kỳ đã tham gia trong thế kỷ 19.',
 'War of 1812; Mexican-American War; Civil War; Spanish-American War.',
 'Chiến Tranh Năm 1812 (War of 1812); Chiến Tranh Mỹ-Mexico; Nội Chiến (Civil War); Chiến Tranh Mỹ-Tây Ban Nha.'),

('naturalization', 'Name the U.S. war between the North and the South.', 'Hãy nêu tên cuộc chiến giữa miền Bắc và miền Nam Hoa Kỳ.',
 'The Civil War.', 'Nội Chiến Hoa Kỳ (the Civil War).'),

('naturalization', 'The Civil War had many important events. Name one.', 'Nội Chiến Hoa Kỳ có nhiều sự kiện quan trọng. Hãy nêu tên một sự kiện.',
 '(Battle of) Fort Sumter; Emancipation Proclamation; (Battle of) Vicksburg; (Battle of) Gettysburg; Sherman''s March; (Surrender at) Appomattox; (Battle of) Antietam/Sharpsburg; Lincoln was assassinated.',
 'Trận Fort Sumter; Tuyên Ngôn Giải Phóng Nô Lệ; Trận Vicksburg; Trận Gettysburg; Cuộc Hành Quân Của Sherman; Đầu Hàng tại Appomattox; Trận Antietam/Sharpsburg; Lincoln bị ám sát.'),

('naturalization', 'Abraham Lincoln is famous for many things. Name one.', 'Abraham Lincoln nổi tiếng với nhiều điều. Hãy nêu tên một điều.',
 'Freed the slaves (Emancipation Proclamation); saved (or preserved) the Union; led the United States during the Civil War; 16th president of the United States; delivered the Gettysburg Address.',
 'Giải phóng nô lệ (Tuyên Ngôn Giải Phóng Nô Lệ); gìn giữ Liên Bang Hoa Kỳ; lãnh đạo Hoa Kỳ trong suốt Nội Chiến; Tổng Thống thứ 16 của Hoa Kỳ; đọc Diễn Văn Gettysburg.'),

('naturalization', 'What did the Emancipation Proclamation do?', 'Tuyên Ngôn Giải Phóng Nô Lệ (Emancipation Proclamation) đã làm gì?',
 'Freed the slaves; freed slaves in the Confederacy; freed slaves in the Confederate states; freed slaves in most Southern states.',
 'Giải phóng nô lệ; giải phóng nô lệ tại các tiểu bang Liên Minh Miền Nam (Confederacy); giải phóng nô lệ ở hầu hết các tiểu bang miền Nam.'),

('naturalization', 'What U.S. war ended slavery?', 'Cuộc chiến nào của Hoa Kỳ đã chấm dứt chế độ nô lệ?',
 'The Civil War.', 'Nội Chiến Hoa Kỳ (the Civil War).'),

('naturalization', 'What amendment says all persons born or naturalized in the United States, and subject to the jurisdiction thereof, are U.S. citizens?', 'Tu chính án nào quy định rằng mọi người sinh ra hoặc nhập tịch tại Hoa Kỳ, và chịu sự quản lý của luật pháp Hoa Kỳ, đều là công dân Hoa Kỳ?',
 '14th Amendment.', 'Tu Chính Án Thứ 14 (14th Amendment).'),

('naturalization', 'When did all men get the right to vote?', 'Khi nào tất cả nam giới có quyền bầu cử?',
 'After the Civil War; during Reconstruction; (with the) 15th Amendment; 1870.',
 'Sau Nội Chiến; trong thời kỳ Tái Thiết (Reconstruction); cùng với Tu Chính Án Thứ 15; năm 1870.'),

('naturalization', 'Name one leader of the women''s rights movement in the 1800s.', 'Hãy nêu tên một nhà lãnh đạo của phong trào quyền phụ nữ trong thế kỷ 19.',
 'Susan B. Anthony; Elizabeth Cady Stanton; Sojourner Truth; Harriet Tubman; Lucretia Mott; Lucy Stone.',
 'Susan B. Anthony; Elizabeth Cady Stanton; Sojourner Truth; Harriet Tubman; Lucretia Mott; Lucy Stone.'),

-- AMERICAN HISTORY — C: Recent American History and Other Important Historical Information
('naturalization', 'Name one war fought by the United States in the 1900s.', 'Hãy nêu tên một cuộc chiến mà Hoa Kỳ đã tham gia trong thế kỷ 20.',
 'World War I; World War II; Korean War; Vietnam War; (Persian) Gulf War.',
 'Thế Chiến I; Thế Chiến II; Chiến Tranh Triều Tiên; Chiến Tranh Việt Nam; Chiến Tranh Vùng Vịnh.'),

('naturalization', 'Why did the United States enter World War I?', 'Vì sao Hoa Kỳ tham gia Thế Chiến I?',
 'Because Germany attacked U.S. (civilian) ships; to support the Allied Powers (England, France, Italy, and Russia); to oppose the Central Powers (Germany, Austria-Hungary, the Ottoman Empire, and Bulgaria).',
 'Vì Đức tấn công tàu (dân sự) của Hoa Kỳ; để ủng hộ phe Đồng Minh (Anh, Pháp, Ý và Nga); để chống lại phe Liên Minh Trung Tâm (Đức, Áo-Hung, Đế Chế Ottoman và Bulgaria).'),

('naturalization', 'When did all women get the right to vote?', 'Khi nào tất cả phụ nữ có quyền bầu cử?',
 '1920; after World War I; (with the) 19th Amendment.',
 'Năm 1920; sau Thế Chiến I; cùng với Tu Chính Án Thứ 19.'),

('naturalization', 'What was the Great Depression?', 'Đại Suy Thoái (Great Depression) là gì?',
 'Longest economic recession in modern history.', 'Cuộc suy thoái kinh tế kéo dài nhất trong lịch sử hiện đại.'),

('naturalization', 'When did the Great Depression start?', 'Đại Suy Thoái bắt đầu khi nào?',
 'The Great Crash (1929); stock market crash of 1929.', 'Sự Sụp Đổ Lớn (1929); sự sụp đổ thị trường chứng khoán năm 1929.'),

('naturalization', 'Who was president during the Great Depression and World War II?', 'Ai là Tổng Thống trong thời kỳ Đại Suy Thoái và Thế Chiến II?',
 '(Franklin) Roosevelt.', '(Franklin) Roosevelt.'),

('naturalization', 'Why did the United States enter World War II?', 'Vì sao Hoa Kỳ tham gia Thế Chiến II?',
 '(Bombing of) Pearl Harbor; Japanese attacked Pearl Harbor; to support the Allied Powers (England, France, and Russia); to oppose the Axis Powers (Germany, Italy, and Japan).',
 'Trận Trân Châu Cảng (Pearl Harbor); Nhật Bản tấn công Trân Châu Cảng; để ủng hộ phe Đồng Minh (Anh, Pháp và Nga); để chống lại phe Trục (Đức, Ý và Nhật Bản).'),

('naturalization', 'Dwight Eisenhower is famous for many things. Name one.', 'Dwight Eisenhower nổi tiếng với nhiều điều. Hãy nêu tên một điều.',
 'General during World War II; president at the end of (during) the Korean War; 34th president of the United States; signed the Federal-Aid Highway Act of 1956 (created the Interstate System).',
 'Đại Tướng trong Thế Chiến II; Tổng Thống vào cuối (trong) Chiến Tranh Triều Tiên; Tổng Thống thứ 34 của Hoa Kỳ; ký Đạo Luật Xa Lộ Liên Bang năm 1956 (tạo ra Hệ Thống Xa Lộ Liên Tiểu Bang).'),

('naturalization', 'Who was the United States'' main rival during the Cold War?', 'Đối thủ chính của Hoa Kỳ trong thời kỳ Chiến Tranh Lạnh là ai?',
 'Soviet Union; USSR; Russia.', 'Liên Xô (Soviet Union); Liên Bang Xô Viết (USSR); Nga.'),

('naturalization', 'During the Cold War, what was one main concern of the United States?', 'Trong thời kỳ Chiến Tranh Lạnh, mối quan tâm chính của Hoa Kỳ là gì?',
 'Communism; nuclear war.', 'Chủ nghĩa Cộng Sản (Communism); chiến tranh hạt nhân.'),

('naturalization', 'Why did the United States enter the Korean War?', 'Vì sao Hoa Kỳ tham gia Chiến Tranh Triều Tiên?',
 'To stop the spread of communism.', 'Để ngăn chặn sự lan rộng của chủ nghĩa Cộng Sản.'),

('naturalization', 'Why did the United States enter the Vietnam War?', 'Vì sao Hoa Kỳ tham gia Chiến Tranh Việt Nam?',
 'To stop the spread of communism.', 'Để ngăn chặn sự lan rộng của chủ nghĩa Cộng Sản.'),

('naturalization', 'What did the civil rights movement do?', 'Phong trào Dân Quyền (civil rights movement) đã làm gì?',
 'Fought to end racial discrimination.', 'Đấu tranh nhằm chấm dứt sự phân biệt chủng tộc.'),

('naturalization', 'Martin Luther King, Jr. is famous for many things. Name one.', 'Martin Luther King, Jr. nổi tiếng với nhiều điều. Hãy nêu tên một điều.',
 'Fought for civil rights; worked for equality for all Americans; worked to ensure that people would "not be judged by the color of their skin, but by the content of their character."',
 'Đấu tranh cho quyền công dân; nỗ lực vì sự bình đẳng cho tất cả người dân Mỹ; nỗ lực để mọi người "không bị đánh giá bởi màu da, mà bởi phẩm chất của họ."'),

('naturalization', 'Why did the United States enter the Persian Gulf War?', 'Vì sao Hoa Kỳ tham gia Chiến Tranh Vùng Vịnh?',
 'To force the Iraqi military from Kuwait.', 'Để buộc quân đội Iraq rút khỏi Kuwait.'),

('naturalization', 'What major event happened on September 11, 2001 in the United States?', 'Sự kiện lớn nào đã xảy ra tại Hoa Kỳ vào ngày 11 tháng 9 năm 2001?',
 'Terrorists attacked the United States; terrorists took over two planes and crashed them into the World Trade Center in New York City; terrorists took over a plane and crashed into the Pentagon in Arlington, Virginia; terrorists took over a plane originally aimed at Washington, D.C., and crashed in a field in Pennsylvania.',
 'Những kẻ khủng bố đã tấn công nước Mỹ; khủng bố chiếm hai máy bay và cho lao vào Trung Tâm Thương Mại Thế Giới tại New York City; khủng bố chiếm một máy bay và cho lao vào Lầu Năm Góc (Pentagon) tại Arlington, Virginia; khủng bố chiếm một máy bay ban đầu nhắm vào Washington, D.C., và máy bay rơi xuống một cánh đồng ở Pennsylvania.'),

('naturalization', 'Name one U.S. military conflict after the September 11, 2001 attacks.', 'Hãy nêu tên một cuộc xung đột quân sự của Hoa Kỳ sau vụ tấn công ngày 11 tháng 9 năm 2001.',
 '(Global) War on Terror; War in Afghanistan; War in Iraq.',
 'Cuộc Chiến Chống Khủng Bố (toàn cầu); Chiến Tranh Afghanistan; Chiến Tranh Iraq.'),

('naturalization', 'Name one American Indian tribe in the United States.', 'Hãy nêu tên một bộ tộc người Da Đỏ Mỹ tại Hoa Kỳ.',
 'Apache, Blackfeet, Cayuga, Cherokee, Cheyenne, Chippewa, Choctaw, Creek, Crow, Hopi, Huron, Inupiat, Lakota, Mohawk, Mohegan, Navajo, Oneida, Onondaga, Pueblo, Seminole, Seneca, Shawnee, Sioux, Teton, Tuscarora (name any one; for the complete list, visit bia.gov).',
 'Apache, Blackfeet, Cayuga, Cherokee, Cheyenne, Chippewa, Choctaw, Creek, Crow, Hopi, Huron, Inupiat, Lakota, Mohawk, Mohegan, Navajo, Oneida, Onondaga, Pueblo, Seminole, Seneca, Shawnee, Sioux, Teton, Tuscarora (nêu tên bất kỳ một bộ tộc nào; xem danh sách đầy đủ tại bia.gov).'),

('naturalization', 'Name one example of an American innovation.', 'Hãy nêu tên một ví dụ về phát minh của Mỹ.',
 'Light bulb; automobile (cars, internal combustion engine); skyscrapers; airplane; assembly line; landing on the moon; integrated circuit (IC).',
 'Bóng đèn điện; ô tô (động cơ đốt trong); nhà chọc trời; máy bay; dây chuyền lắp ráp; đổ bộ lên mặt trăng; mạch tích hợp (IC).'),

-- SYMBOLS AND HOLIDAYS — A: Symbols
('naturalization', 'What is the capital of the United States?', 'Thủ đô của Hoa Kỳ là gì?',
 'Washington, D.C.', 'Washington, D.C.'),

('naturalization', 'Where is the Statue of Liberty?', 'Tượng Nữ Thần Tự Do nằm ở đâu?',
 'New York Harbor; Liberty Island (also acceptable: New Jersey, near New York City, on the Hudson River).',
 'Cảng New York; Đảo Liberty (Liberty Island) (cũng có thể trả lời: New Jersey, gần thành phố New York, trên sông Hudson).'),

('naturalization', 'Why does the flag have 13 stripes?', 'Vì sao lá cờ Mỹ có 13 sọc?',
 '(Because there were) 13 original colonies; (because the stripes) represent the original colonies.',
 'Vì có 13 thuộc địa ban đầu; các sọc đại diện cho 13 thuộc địa ban đầu.'),

('naturalization', 'Why does the flag have 50 stars?', 'Vì sao lá cờ Mỹ có 50 ngôi sao?',
 '(Because there is) one star for each state; (because) each star represents a state; (because there are) 50 states.',
 'Vì mỗi ngôi sao đại diện cho một tiểu bang; hiện có 50 tiểu bang.'),

('naturalization', 'What is the name of the national anthem?', 'Quốc ca của Hoa Kỳ có tên là gì?',
 'The Star-Spangled Banner.', '"The Star-Spangled Banner".'),

('naturalization', 'The Nation''s first motto was "E Pluribus Unum." What does that mean?', 'Khẩu hiệu đầu tiên của đất nước là "E Pluribus Unum." Cụm từ này có nghĩa là gì?',
 'Out of many, one; we all become one.', 'Từ nhiều thành một; tất cả chúng ta hợp thành một.'),

-- SYMBOLS AND HOLIDAYS — B: Holidays
('naturalization', 'What is Independence Day?', 'Ngày Độc Lập (Independence Day) là gì?',
 'A holiday to celebrate U.S. independence (from Britain); the country''s birthday.',
 'Ngày lễ kỷ niệm nền độc lập của Hoa Kỳ (khỏi Anh Quốc); ngày sinh nhật của đất nước.'),

('naturalization', 'Name three national U.S. holidays.', 'Hãy nêu tên ba ngày lễ quốc gia của Hoa Kỳ.',
 'New Year''s Day, Martin Luther King, Jr. Day, Presidents Day (Washington''s Birthday), Memorial Day, Juneteenth, Independence Day, Labor Day, Columbus Day, Veterans Day, Thanksgiving Day, Christmas Day (name any three).',
 'Tết Dương Lịch, Ngày Martin Luther King Jr., Ngày Tổng Thống (Sinh Nhật Washington), Ngày Chiến Sĩ Trận Vong (Memorial Day), Ngày Juneteenth, Ngày Độc Lập, Ngày Lao Động, Ngày Columbus, Ngày Cựu Chiến Binh, Lễ Tạ Ơn, Giáng Sinh (nêu tên bất kỳ ba ngày lễ nào).'),

('naturalization', 'What is Memorial Day?', 'Ngày Chiến Sĩ Trận Vong (Memorial Day) là gì?',
 'A holiday to honor soldiers who died in military service.', 'Ngày lễ để tưởng nhớ những binh sĩ đã hy sinh khi phục vụ quân đội.'),

('naturalization', 'What is Veterans Day?', 'Ngày Cựu Chiến Binh (Veterans Day) là gì?',
 'A holiday to honor people in the (U.S.) military; a holiday to honor people who have served (in the U.S. military).',
 'Ngày lễ để tôn vinh những người trong quân đội Hoa Kỳ; ngày lễ để tôn vinh những người đã từng phục vụ trong quân đội Hoa Kỳ.'),

-- Bonus practical prep question (not an official civics test question)
('naturalization', 'How long have you lived at your current address, and where did you live before that?', 'Anh/chị đã sống tại địa chỉ hiện tại bao lâu, và trước đó sống ở đâu?',
 'Have your full address history ready with move-in dates — this should match exactly what you listed on Form N-400.',
 'Hãy chuẩn bị sẵn toàn bộ lịch sử địa chỉ cư trú kèm ngày chuyển đến — thông tin này cần khớp chính xác với những gì đã khai trong Mẫu N-400.'),


-- ── Asylum interview ─────────────────────────────────────────────────
('asylum', 'Why did you leave your home country?', 'Vì sao anh/chị rời khỏi quê hương?',
 'Give a clear, chronological account of the events that led to your fear of persecution. Consistency with your written asylum application (Form I-589) is critical.',
 'Hãy trình bày rõ ràng, theo trình tự thời gian các sự kiện dẫn đến nỗi sợ bị đàn áp. Sự nhất quán với đơn xin tị nạn đã nộp (Mẫu I-589) là yếu tố then chốt.'),

('asylum', 'What specifically happened to you that made you afraid to return?', 'Cụ thể điều gì đã xảy ra khiến anh/chị sợ phải quay về?',
 'Describe specific incidents with dates, locations, and who was involved, rather than general statements. Specific, sensory details strengthen credibility.',
 'Hãy mô tả các sự việc cụ thể kèm ngày tháng, địa điểm và những người liên quan, thay vì chỉ nói chung chung. Các chi tiết cụ thể, sống động sẽ tăng độ tin cậy cho câu trả lời.'),

('asylum', 'Who harmed or threatened you, and why do you believe they targeted you?', 'Ai là người đã làm hại hoặc đe dọa anh/chị, và vì sao anh/chị tin rằng mình bị nhắm đến?',
 'Connect the harm to one of the five protected grounds: race, religion, nationality, political opinion, or membership in a particular social group.',
 'Hãy liên kết sự việc bị hại với một trong năm căn cứ được bảo vệ: chủng tộc, tôn giáo, quốc tịch, quan điểm chính trị, hoặc là thành viên của một nhóm xã hội cụ thể.'),

('asylum', 'Did you report the incident to the police or any authority? What happened?', 'Anh/chị có trình báo sự việc với công an hay cơ quan chức năng nào không? Kết quả ra sao?',
 'If you did not report it, be ready to explain why (e.g., fear of the authorities themselves, lack of protection). If you did report it, describe the outcome honestly.',
 'Nếu chưa trình báo, hãy chuẩn bị giải thích lý do (ví dụ: sợ chính quyền, không được bảo vệ). Nếu đã trình báo, hãy trình bày trung thực kết quả, kể cả khi cơ quan chức năng không xử lý gì.'),

('asylum', 'Have you ever been arrested, detained, or imprisoned in your home country?', 'Anh/chị đã từng bị bắt, giam giữ hoặc bỏ tù tại quê nhà chưa?',
 'Answer truthfully and completely — this is cross-checked against background records. Explain the circumstances and how it relates to your claim.',
 'Hãy trả lời trung thực và đầy đủ — thông tin này sẽ được đối chiếu với hồ sơ lý lịch. Giải thích rõ hoàn cảnh và mối liên hệ với đơn xin tị nạn của anh/chị.'),

('asylum', 'When did you leave your home country, and how did you travel to the United States?', 'Anh/chị rời quê hương khi nào, và đã đến Hoa Kỳ bằng cách nào?',
 'Give an accurate travel timeline — dates, countries passed through, and method of travel — matching your I-589 and any entry records.',
 'Hãy trình bày chính xác dòng thời gian di chuyển — ngày tháng, các quốc gia đã đi qua, phương tiện di chuyển — khớp với Mẫu I-589 và các hồ sơ nhập cảnh.'),

('asylum', 'Did you stay in any other countries before arriving in the United States? Why didn''t you apply for asylum there?', 'Anh/chị có ở lại quốc gia nào khác trước khi đến Hoa Kỳ không? Vì sao không xin tị nạn ở đó?',
 'Explain why those countries were not safe or viable options for permanent protection — this addresses the "firm resettlement" issue officers look for.',
 'Hãy giải thích vì sao những quốc gia đó không an toàn hoặc không phải là lựa chọn khả thi để được bảo vệ lâu dài — điều này giải quyết vấn đề "định cư vững chắc" mà viên chức thường xem xét.'),

('asylum', 'Have you returned to your home country since you left? If so, why?', 'Anh/chị có quay lại quê nhà kể từ khi rời đi không? Nếu có, vì sao?',
 'Returning can undermine a fear-based claim unless there''s a well-explained, compelling reason (e.g., a family emergency), so be ready to explain the circumstances clearly.',
 'Việc quay lại quê nhà có thể làm suy yếu đơn xin tị nạn dựa trên nỗi sợ hãi, trừ khi có lý do chính đáng và thuyết phục (ví dụ: việc gia đình khẩn cấp) — hãy chuẩn bị giải thích rõ hoàn cảnh.'),

('asylum', 'What do you fear would happen to you if you were returned to your home country today?', 'Anh/chị sợ điều gì sẽ xảy ra nếu bị trả về quê nhà ngay hôm nay?',
 'State your fear clearly and connect it to concrete, current evidence (recent threats, ongoing conflict), not just general country conditions.',
 'Hãy nêu rõ nỗi sợ hãi và liên kết với bằng chứng cụ thể, hiện tại (đe dọa gần đây, xung đột đang diễn ra), chứ không chỉ nói chung chung về tình hình đất nước.'),

('asylum', 'Is there any part of your home country where you believe you could live safely?', 'Có nơi nào ở quê nhà mà anh/chị tin rằng mình có thể sống an toàn không?',
 'This addresses "internal relocation." If no safe area exists, explain why the danger reaches you nationwide.',
 'Câu hỏi này liên quan đến khả năng "di dời trong nước". Nếu không có nơi nào an toàn, hãy giải thích vì sao mối nguy hiểm lan rộng khắp cả nước.'),

('asylum', 'Have any of your family members experienced similar harm or threats?', 'Có thành viên nào trong gia đình anh/chị từng gặp phải sự hại hoặc đe dọa tương tự không?',
 'Corroborating harm to family members for the same reason strengthens your claim — provide names, relationship, and details if applicable.',
 'Việc có người thân trong gia đình cũng bị hại vì cùng lý do sẽ củng cố đơn xin tị nạn — hãy cung cấp tên, mối quan hệ và chi tiết cụ thể nếu có.'),

('asylum', 'Do you belong to a particular social, religious, political, or ethnic group connected to your claim?', 'Anh/chị có thuộc về một nhóm xã hội, tôn giáo, chính trị hoặc sắc tộc cụ thể nào liên quan đến đơn xin tị nạn không?',
 'Clearly identify the group and explain how membership in it is the reason you were targeted — this maps directly to the legal definition of a refugee.',
 'Hãy xác định rõ nhóm đó và giải thích vì sao việc thuộc nhóm này là lý do khiến anh/chị bị nhắm đến — điều này liên hệ trực tiếp đến định nghĩa pháp lý về người tị nạn.'),

('asylum', 'You are required to file for asylum within one year of arriving in the United States. When did you file, and if it was late, why?', 'Anh/chị phải nộp đơn xin tị nạn trong vòng một năm kể từ khi đến Hoa Kỳ. Anh/chị đã nộp đơn khi nào, và nếu nộp trễ, vì sao?',
 'Know your exact filing date. If you filed after the one-year deadline, be ready to explain the "changed circumstances" or "extraordinary circumstances" that excuse the delay (e.g., serious illness, legal disability, changed country conditions).',
 'Cần biết chính xác ngày đã nộp đơn. Nếu nộp sau thời hạn một năm, hãy chuẩn bị giải thích "hoàn cảnh thay đổi" hoặc "hoàn cảnh đặc biệt" khiến việc nộp trễ được chấp nhận (ví dụ: bệnh nặng, mất năng lực pháp lý, tình hình đất nước thay đổi).'),

('asylum', 'What evidence do you have to support your claim, such as documents, photos, medical records, or witness statements?', 'Anh/chị có bằng chứng gì để hỗ trợ đơn xin tị nạn, chẳng hạn như giấy tờ, hình ảnh, hồ sơ y tế, hay lời khai của nhân chứng?',
 'List everything you''re submitting: police reports, medical/psychological evaluations, news articles, photos of injuries, letters from witnesses or family. Corroborating evidence significantly strengthens credibility, though it is not always required.',
 'Hãy liệt kê mọi thứ đang nộp kèm: biên bản công an, đánh giá y tế/tâm lý, bài báo, hình ảnh vết thương, thư từ nhân chứng hoặc gia đình. Bằng chứng bổ trợ giúp tăng đáng kể độ tin cậy, dù không phải lúc nào cũng bắt buộc.'),

('asylum', 'Have you received any medical or psychological treatment related to the harm you experienced?', 'Anh/chị có từng được điều trị y tế hoặc tâm lý liên quan đến những tổn hại đã trải qua không?',
 'If you have, bring records or a letter from the provider — this can corroborate both the harm and its lasting impact. If you haven''t sought treatment, be ready to explain why (cost, access, stigma, fear).',
 'Nếu có, hãy mang theo hồ sơ hoặc thư từ bác sĩ/chuyên gia điều trị — điều này giúp củng cố cả sự việc lẫn tác động lâu dài. Nếu chưa từng điều trị, hãy chuẩn bị giải thích lý do (chi phí, khả năng tiếp cận, kỳ thị xã hội, nỗi sợ hãi).'),

('asylum', 'Is your fear based on past persecution, a fear of future persecution, or both?', 'Nỗi sợ của anh/chị dựa trên sự đàn áp đã xảy ra trong quá khứ, nỗi sợ bị đàn áp trong tương lai, hay cả hai?',
 'Understand the distinction: past persecution can create a presumption of future risk, but the government can try to rebut it with evidence of changed country conditions. Be clear about which applies to your case, or if both do.',
 'Cần hiểu rõ sự khác biệt: từng bị đàn áp trong quá khứ có thể tạo ra một giả định về nguy cơ trong tương lai, nhưng chính phủ có thể phản bác bằng bằng chứng cho thấy tình hình đất nước đã thay đổi. Hãy trình bày rõ trường hợp của anh/chị thuộc dạng nào, hoặc cả hai.'),

('asylum', 'Have you applied for or received asylum or any other immigration status in another country?', 'Anh/chị đã từng nộp đơn hoặc được cấp quy chế tị nạn hay bất kỳ tình trạng di trú nào khác ở một quốc gia khác chưa?',
 'This can affect eligibility under "firm resettlement" rules. Answer honestly and be ready to explain the outcome and why that status didn''t provide lasting safety, if applicable.',
 'Điều này có thể ảnh hưởng đến điều kiện xin tị nạn theo quy định "định cư vững chắc" (firm resettlement). Hãy trả lời trung thực và chuẩn bị giải thích kết quả cũng như lý do vì sao quy chế đó không mang lại sự an toàn lâu dài, nếu có.'),

('asylum', 'Do you have any family members — spouse or children — who could be included in your asylum application?', 'Anh/chị có thành viên gia đình nào — vợ/chồng hoặc con cái — có thể được đưa vào đơn xin tị nạn của mình không?',
 'A spouse and unmarried children under 21 can often be included as derivatives. Have their full names, dates of birth, and current locations ready.',
 'Vợ/chồng và con cái chưa lập gia đình dưới 21 tuổi thường có thể được đưa vào đơn xin tị nạn với tư cách người phụ thuộc (derivative). Cần chuẩn bị sẵn họ tên đầy đủ, ngày sinh và nơi ở hiện tại của họ.'),

('asylum', 'Why can''t you simply relocate to a different city or region within your home country to be safe?', 'Vì sao anh/chị không thể đơn giản chuyển đến một thành phố hoặc khu vực khác trong nước để được an toàn?',
 'This addresses the "internal relocation" question directly. Explain why the threat follows you nationwide — for example, the persecutor has government ties or a national reach, or the danger is tied to a national policy or widespread social attitude.',
 'Câu này liên quan trực tiếp đến vấn đề "di dời trong nước". Hãy giải thích vì sao mối đe dọa vẫn tồn tại trên toàn quốc — ví dụ, người đàn áp có liên hệ với chính quyền hoặc có tầm ảnh hưởng toàn quốc, hoặc mối nguy hiểm gắn liền với chính sách quốc gia hay thái độ xã hội phổ biến.'),

-- ── F-1 Student Visa (consular interview) ───────────────────────────
-- These are "coaching tips" answers, like marriage and asylum. The
-- single biggest factor in an F-1 approval is convincing the officer
-- you have strong ties to Vietnam and genuine intent to return home
-- after your studies (INA 214(b)) — most tips below point back to that.

('f1', 'Why do you want to study in the United States?', 'Vì sao anh/chị muốn du học tại Hoa Kỳ?',
 'Give a specific, personal reason tied to your field and career goals — not a generic answer like "for a better future." Mention what U.S. education offers that you can''t get at home (specific program strengths, research opportunities, industry connections).',
 'Hãy đưa ra lý do cụ thể, gắn liền với ngành học và mục tiêu nghề nghiệp của bản thân — tránh câu trả lời chung chung như "để có tương lai tốt hơn". Nêu rõ điều gì ở nền giáo dục Mỹ mà anh/chị không thể có được ở trong nước (thế mạnh cụ thể của chương trình, cơ hội nghiên cứu, kết nối với ngành nghề).'),

('f1', 'Why did you choose this particular school?', 'Vì sao anh/chị chọn trường này?',
 'Know specific facts about the school — its ranking or reputation in your field, particular professors or programs, location, or cost compared to alternatives. Officers want to see real research went into the decision, not just an agent''s recommendation.',
 'Cần biết các thông tin cụ thể về trường — thứ hạng hoặc uy tín trong ngành học, giáo sư hoặc chương trình cụ thể, vị trí địa lý, hoặc chi phí so với các lựa chọn khác. Viên chức muốn thấy anh/chị đã thật sự tìm hiểu kỹ trước khi quyết định, không chỉ nghe theo tư vấn của trung tâm.'),

('f1', 'What will you study, and why did you choose this major?', 'Anh/chị sẽ học ngành gì, và vì sao chọn ngành này?',
 'Connect your major to your academic background and future career plans in Vietnam. If you''re switching fields, be ready to explain why clearly and confidently.',
 'Hãy liên kết ngành học với nền tảng học vấn trước đây và kế hoạch nghề nghiệp tương lai tại Việt Nam. Nếu chuyển sang một lĩnh vực khác, hãy chuẩn bị giải thích rõ ràng và tự tin lý do thay đổi.'),

('f1', 'What are your plans after you graduate?', 'Kế hoạch của anh/chị sau khi tốt nghiệp là gì?',
 'State clearly that you plan to return to Vietnam and explain what you''ll do there — a specific job, joining a family business, or a career path this degree prepares you for. This is the single most important question for overcoming presumption of immigrant intent.',
 'Hãy khẳng định rõ ràng rằng anh/chị dự định quay về Việt Nam và trình bày cụ thể sẽ làm gì ở đó — một công việc cụ thể, tiếp nối công việc kinh doanh gia đình, hoặc con đường sự nghiệp mà tấm bằng này chuẩn bị cho anh/chị. Đây là câu hỏi quan trọng nhất để vượt qua giả định có ý định định cư (immigrant intent).'),

('f1', 'Do you have family or close relatives currently living in the United States?', 'Anh/chị có người thân hoặc họ hàng gần đang sinh sống tại Hoa Kỳ không?',
 'Answer honestly. Having close family (especially a parent or sibling) already in the U.S. can raise immigrant-intent concerns, so be ready to explain your independent ties and reasons to return to Vietnam regardless.',
 'Hãy trả lời trung thực. Có người thân gần (đặc biệt là cha mẹ hoặc anh chị em) đang sống tại Hoa Kỳ có thể khiến viên chức lo ngại về ý định định cư, vì vậy hãy chuẩn bị giải thích rõ những ràng buộc độc lập và lý do quay về Việt Nam của bản thân.'),

('f1', 'Who is paying for your education, and what is their relationship to you?', 'Ai là người chi trả cho việc học của anh/chị, và người đó có quan hệ gì với anh/chị?',
 'Know your sponsor''s full name, occupation, and relationship to you clearly. If a parent is sponsoring you, be ready to describe their job and how they earn the income shown on your financial documents.',
 'Cần biết rõ họ tên đầy đủ, nghề nghiệp của người bảo trợ tài chính, và mối quan hệ với anh/chị. Nếu cha mẹ là người bảo trợ, hãy chuẩn bị mô tả công việc của họ và cách họ tạo ra nguồn thu nhập thể hiện trong hồ sơ tài chính.'),

('f1', 'How much does your program cost per year, and how will you cover tuition and living expenses?', 'Chương trình học của anh/chị tốn bao nhiêu mỗi năm, và anh/chị sẽ trang trải học phí và chi phí sinh hoạt như thế nào?',
 'Know the actual tuition and living cost figures for your specific school and be able to state the total for the full program, not just year one. Explain the funding source clearly: savings, sponsor income, scholarship, or a combination.',
 'Cần biết số tiền học phí và chi phí sinh hoạt thực tế của trường mình, và có thể nêu tổng chi phí cho cả chương trình học, không chỉ năm đầu tiên. Giải thích rõ nguồn tài trợ: tiền tiết kiệm, thu nhập của người bảo trợ, học bổng, hoặc kết hợp nhiều nguồn.'),

('f1', 'Can you explain the source of the funds in your bank statement?', 'Anh/chị có thể giải thích nguồn gốc số tiền trong sao kê ngân hàng không?',
 'Be ready to explain exactly where the money came from — years of savings, sale of property, business income, or a loan — and that it matches your sponsor''s stated occupation and income level. A large, unexplained recent deposit is a common red flag.',
 'Hãy chuẩn bị giải thích chính xác nguồn gốc số tiền — tiết kiệm nhiều năm, bán tài sản, thu nhập kinh doanh, hoặc vay ngân hàng — và số tiền đó phải phù hợp với nghề nghiệp và mức thu nhập đã khai của người bảo trợ. Một khoản tiền lớn mới nộp vào tài khoản mà không giải thích được là một dấu hiệu đáng ngờ phổ biến.'),

('f1', 'What ties do you have to Vietnam that would bring you back after your studies?', 'Anh/chị có những ràng buộc gì với Việt Nam khiến anh/chị sẽ quay về sau khi học xong?',
 'Be specific: family you''re close to, a job or career path waiting for you, property, or a family business. Vague answers like "I love my country" are far less convincing than concrete plans and obligations.',
 'Hãy nêu cụ thể: gia đình mà anh/chị gắn bó, công việc hoặc con đường sự nghiệp đang chờ đợi, tài sản, hoặc công việc kinh doanh gia đình. Câu trả lời mơ hồ như "tôi yêu quê hương" sẽ kém thuyết phục hơn nhiều so với các kế hoạch và ràng buộc cụ thể.'),

('f1', 'Why didn''t you choose to study this subject in Vietnam?', 'Vì sao anh/chị không chọn học ngành này tại Việt Nam?',
 'Give a genuine, specific comparison — program quality, hands-on research opportunities, industry exposure, or a specialization not widely offered at home — rather than implying Vietnamese education is generally inferior.',
 'Hãy đưa ra sự so sánh thật sự, cụ thể — chất lượng chương trình, cơ hội nghiên cứu thực hành, tiếp xúc với ngành nghề, hoặc một chuyên ngành chưa phổ biến trong nước — thay vì ngụ ý rằng giáo dục Việt Nam nói chung kém hơn.'),

('f1', 'What English proficiency test did you take, and what was your score?', 'Anh/chị đã thi chứng chỉ tiếng Anh nào, và điểm số là bao nhiêu?',
 'Know your exact TOEFL or IELTS score and the date you took it. If your score is on the lower end for your program, be ready to mention any conditional admission, an English pathway program, or additional preparation you''ve done.',
 'Cần biết chính xác điểm TOEFL hoặc IELTS và ngày thi. Nếu điểm số ở mức thấp so với yêu cầu chương trình, hãy chuẩn bị đề cập đến việc nhập học có điều kiện, chương trình tiếng Anh dự bị, hoặc quá trình ôn luyện thêm đã thực hiện.'),

('f1', 'Have you ever traveled to the United States or any other country before?', 'Anh/chị đã từng đến Hoa Kỳ hoặc bất kỳ quốc gia nào khác trước đây chưa?',
 'If you have, be ready to state the purpose, dates, and confirm you always returned to Vietnam on time — a clean travel history is strong evidence you honor visa terms. If this is your first trip abroad, that''s fine too; just answer honestly.',
 'Nếu đã từng đi, hãy chuẩn bị nêu rõ mục đích, thời gian, và xác nhận luôn quay về Việt Nam đúng hạn — lịch sử du lịch rõ ràng là bằng chứng mạnh cho thấy anh/chị tuân thủ đúng thời hạn visa. Nếu đây là chuyến đi nước ngoài đầu tiên, điều đó cũng hoàn toàn bình thường; chỉ cần trả lời trung thực.'),

('f1', 'Have you ever been denied a U.S. visa before?', 'Anh/chị đã từng bị từ chối cấp visa Hoa Kỳ trước đây chưa?',
 'If yes, say so honestly and briefly explain what has changed since then (stronger ties, clearer study plan, better financial documentation) rather than dwelling on the denial itself.',
 'Nếu có, hãy trả lời trung thực và giải thích ngắn gọn những gì đã thay đổi kể từ lần đó (ràng buộc với quê hương rõ ràng hơn, kế hoạch học tập cụ thể hơn, hồ sơ tài chính đầy đủ hơn) thay vì tập trung vào việc từng bị từ chối.'),

('f1', 'What will your parents or family do while you are studying abroad?', 'Gia đình anh/chị sẽ như thế nào trong thời gian anh/chị du học?',
 'This question probes whether your whole family intends to relocate to the U.S. Make clear that your parents/siblings will continue living and working in Vietnam, which supports your own intent to return.',
 'Câu hỏi này nhằm tìm hiểu xem liệu cả gia đình anh/chị có ý định chuyển sang Mỹ hay không. Hãy nói rõ rằng cha mẹ/anh chị em vẫn sẽ tiếp tục sinh sống và làm việc tại Việt Nam, điều này củng cố ý định quay về của chính anh/chị.'),

('f1', 'How long is your program, and what degree will you receive at the end?', 'Chương trình học kéo dài bao lâu, và anh/chị sẽ nhận bằng cấp gì khi hoàn thành?',
 'Know the exact duration (e.g., "a 2-year Master''s program") and degree name. This shows you have a clear, finite plan rather than an open-ended stay.',
 'Cần biết chính xác thời lượng chương trình (ví dụ: "chương trình Thạc sĩ 2 năm") và tên bằng cấp. Điều này cho thấy anh/chị có một kế hoạch rõ ràng, có thời hạn cụ thể chứ không phải ở lại vô thời hạn.'),

('f1', 'Do you plan to work while studying in the United States?', 'Anh/chị có dự định đi làm trong thời gian du học tại Hoa Kỳ không?',
 'If you mention on-campus work or CPT/OPT, describe it accurately as a limited, program-related option — not as a way to support yourself financially instead of your sponsor. Your financial documents should already show you don''t need to work to cover costs.',
 'Nếu đề cập đến việc làm trong khuôn viên trường hoặc chương trình CPT/OPT, hãy mô tả chính xác đây là lựa chọn có giới hạn, gắn liền với chương trình học — không phải là cách để tự trang trải tài chính thay vì dựa vào người bảo trợ. Hồ sơ tài chính của anh/chị đã cần thể hiện rằng không cần phải đi làm để trang trải chi phí.'),

('f1', 'What will you do if your visa application is denied today?', 'Anh/chị sẽ làm gì nếu đơn xin visa bị từ chối hôm nay?',
 'Stay calm and answer briefly and honestly — you can say you would review the reason for denial and consider reapplying once circumstances change. Do not argue with the officer or become emotional; this can hurt future applications more than the denial itself.',
 'Hãy giữ bình tĩnh và trả lời ngắn gọn, trung thực — có thể nói rằng anh/chị sẽ xem xét lý do bị từ chối và cân nhắc nộp đơn lại khi hoàn cảnh thay đổi. Không nên tranh cãi với viên chức hay tỏ ra xúc động, vì điều này có thể ảnh hưởng xấu đến các lần nộp đơn sau còn hơn cả việc bị từ chối lần này.');
