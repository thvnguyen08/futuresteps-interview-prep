-- One-time migration to add the "b1b2" (B1/B2 visitor visa) category to an
-- already-deployed database. Run this once in the Supabase SQL editor
-- (Project → SQL Editor → New query). Safe to run even if some of it has
-- already been applied, except the inserts, which would duplicate rows if
-- run twice — run this file exactly once.

-- 1. Widen the category check constraint to allow 'b1b2'.
alter table questions drop constraint if exists questions_category_check;
alter table questions add constraint questions_category_check
  check (category in ('marriage', 'naturalization', 'asylum', 'f1', 'b1b2'));

-- 2. Seed starter B1/B2 (tourist/business visitor visa) interview questions.
-- Like marriage/asylum/F-1, these are judgment/personal-history questions
-- with no single correct answer, so answer_* holds coaching tips.
insert into questions (category, question_en, question_vi, answer_en, answer_vi) values

('b1b2', 'What is the purpose of your trip to the United States?', 'Mục đích chuyến đi Mỹ của anh/chị là gì?',
 'Give one clear, simple reason (tourism, visiting family, a short business trip) and be consistent with your DS-160 form. Avoid vague or multiple overlapping reasons — officers want a single, easy-to-verify purpose.',
 'Hãy đưa ra một lý do rõ ràng, đơn giản (du lịch, thăm gia đình, công tác ngắn hạn) và khớp với mẫu đơn DS-160. Tránh lý do mơ hồ hoặc nhiều lý do chồng chéo — viên chức muốn một mục đích rõ ràng, dễ kiểm chứng.'),

('b1b2', 'How long do you plan to stay in the United States?', 'Anh/chị dự định ở Mỹ trong bao lâu?',
 'Give a specific, realistic timeframe that matches your itinerary and return ticket. A B1/B2 visa allows up to 6 months per entry, but stating an unnecessarily long trip raises doubt about your intent to return.',
 'Hãy nêu khoảng thời gian cụ thể, hợp lý và khớp với lịch trình cũng như vé khứ hồi. Visa B1/B2 cho phép ở tối đa 6 tháng mỗi lần nhập cảnh, nhưng nếu nói thời gian ở quá dài sẽ khiến viên chức nghi ngờ ý định quay về.'),

('b1b2', 'Who is paying for your trip?', 'Ai là người chi trả cho chuyến đi của anh/chị?',
 'Be honest and specific — yourself, your employer, or a relative/host in the U.S. If someone else is sponsoring you, be ready to explain your relationship to them and roughly how much the trip will cost.',
 'Hãy trả lời trung thực và cụ thể — tự anh/chị chi trả, công ty, hay người thân/người mời ở Mỹ. Nếu có người khác tài trợ, hãy sẵn sàng giải thích mối quan hệ với người đó và chi phí chuyến đi ước tính.'),

('b1b2', 'Do you have relatives or friends currently living in the United States?', 'Anh/chị có người thân hoặc bạn bè hiện đang sống ở Mỹ không?',
 'Answer truthfully. Having family in the U.S. is not automatically disqualifying, but be ready to explain their immigration status and why that doesn''t change your own plan to return to Vietnam.',
 'Hãy trả lời trung thực. Có người thân ở Mỹ không tự động khiến hồ sơ bị từ chối, nhưng cần sẵn sàng giải thích tình trạng cư trú của họ và vì sao điều đó không thay đổi kế hoạch quay về Việt Nam của anh/chị.'),

('b1b2', 'What is your occupation, and how long have you worked there?', 'Anh/chị đang làm nghề gì, và đã làm việc đó bao lâu rồi?',
 'Know your job title, employer name, and length of employment cold. A stable job is one of the strongest signs of ties to Vietnam — bring a letter from your employer confirming your position and approved leave if you have one.',
 'Cần nhớ rõ chức danh, tên công ty và thời gian đã làm việc. Công việc ổn định là một trong những bằng chứng mạnh nhất cho thấy anh/chị có ràng buộc với Việt Nam — nếu có, hãy mang theo thư xác nhận công việc và thời gian nghỉ phép được duyệt từ công ty.'),

('b1b2', 'What ties do you have that will bring you back to Vietnam — job, family, property?', 'Anh/chị có những ràng buộc gì để chắc chắn quay về Việt Nam — công việc, gia đình, tài sản?',
 'This is the single most important question for a visitor visa. List concrete, specific ties: a job you''d lose, children or elderly parents depending on you, property or a business you own. Vague answers like "I love Vietnam" are not convincing.',
 'Đây là câu hỏi quan trọng nhất đối với visa du lịch/công tác. Hãy liệt kê những ràng buộc cụ thể, rõ ràng: công việc sẽ mất nếu ở lại, con cái hoặc cha mẹ già đang phụ thuộc vào anh/chị, tài sản hoặc công việc kinh doanh đang sở hữu. Câu trả lời chung chung như "tôi yêu Việt Nam" sẽ không thuyết phục.'),

('b1b2', 'Have you traveled internationally before? Where, and when?', 'Anh/chị đã từng đi du lịch nước ngoài trước đây chưa? Ở đâu, và khi nào?',
 'A history of traveling abroad and returning home on time (especially to visa-strict countries like the U.S., UK, Australia, Japan, or Schengen states) is strong evidence you''ll comply with visa terms again. Bring your passport with prior visas/stamps if you have them.',
 'Lịch sử từng đi nước ngoài và quay về đúng hạn (đặc biệt đến các nước xét visa chặt như Mỹ, Anh, Úc, Nhật, hoặc khối Schengen) là bằng chứng mạnh cho thấy anh/chị sẽ tuân thủ điều kiện visa lần này. Nếu có, hãy mang theo hộ chiếu có các visa/dấu nhập cảnh trước đây.'),

('b1b2', 'Have you ever been denied a U.S. visa, or had a visa revoked or an entry refused?', 'Anh/chị đã từng bị từ chối visa Mỹ, bị hủy visa, hoặc bị từ chối nhập cảnh chưa?',
 'You must answer honestly — this is checked against U.S. government records. If you were denied before, be ready to briefly explain what has changed since then (new job, more savings, stronger ties) rather than getting defensive.',
 'Anh/chị phải trả lời trung thực — thông tin này được đối chiếu với hồ sơ của chính phủ Mỹ. Nếu từng bị từ chối trước đây, hãy sẵn sàng giải thích ngắn gọn điều gì đã thay đổi kể từ đó (công việc mới, tài chính vững hơn, ràng buộc mạnh hơn) thay vì phản ứng phòng thủ.'),

('b1b2', 'Do you own property or a business in Vietnam?', 'Anh/chị có sở hữu bất động sản hoặc kinh doanh gì ở Việt Nam không?',
 'Property ownership, a registered business, or a long-term lease are concrete ties to your home country. Know approximate values and be ready to briefly describe them — you don''t need to bring documents unless asked.',
 'Sở hữu bất động sản, có giấy phép kinh doanh, hoặc hợp đồng thuê nhà dài hạn là những ràng buộc cụ thể với quê hương. Hãy nắm giá trị ước tính và sẵn sàng mô tả ngắn gọn — không cần mang giấy tờ trừ khi được yêu cầu.'),

('b1b2', 'What is your approximate monthly or annual income?', 'Thu nhập hàng tháng hoặc hàng năm của anh/chị khoảng bao nhiêu?',
 'Give an honest, approximate figure that matches your bank statements or pay stubs. Sufficient, stable income shows you can afford the trip and don''t need to work illegally in the U.S.',
 'Hãy đưa ra con số ước tính trung thực, khớp với sao kê ngân hàng hoặc phiếu lương. Thu nhập đủ và ổn định cho thấy anh/chị có khả năng chi trả chuyến đi và không cần làm việc bất hợp pháp tại Mỹ.'),

('b1b2', 'Who will be traveling with you?', 'Ai sẽ đi cùng anh/chị trong chuyến đi này?',
 'Name who is traveling with you, if anyone (spouse, children, colleagues). If you''re traveling alone while your spouse and children stay in Vietnam, that''s actually a strong sign you intend to return.',
 'Hãy nêu tên người đi cùng, nếu có (vợ/chồng, con cái, đồng nghiệp). Nếu anh/chị đi một mình trong khi vợ/chồng và con cái ở lại Việt Nam, đây thực chất là dấu hiệu mạnh cho thấy anh/chị có ý định quay về.'),

('b1b2', 'Where will you be staying in the United States?', 'Anh/chị sẽ ở đâu khi đến Mỹ?',
 'Know the city and, if possible, the specific address — a relative''s home, a friend''s house, or a hotel you''ve booked. Vague answers like "I don''t know yet" suggest a poorly planned or pretextual trip.',
 'Hãy biết rõ thành phố và nếu có thể, địa chỉ cụ thể — nhà người thân, nhà bạn bè, hoặc khách sạn đã đặt. Câu trả lời mơ hồ như "tôi chưa biết" cho thấy chuyến đi có vẻ chưa được lên kế hoạch kỹ hoặc không rõ mục đích.'),

('b1b2', 'Do you have an invitation letter from someone in the U.S.? What is your relationship to them?', 'Anh/chị có thư mời từ ai đó ở Mỹ không? Mối quan hệ của anh/chị với người đó là gì?',
 'If you have an invitation letter, know exactly who wrote it, their immigration status, and how you know them. Officers may ask this even if you don''t bring the letter, so the relationship should be clear and consistent with your other answers.',
 'Nếu có thư mời, hãy biết rõ ai là người viết, tình trạng cư trú của họ ở Mỹ, và anh/chị quen biết họ như thế nào. Viên chức có thể hỏi điều này ngay cả khi anh/chị không mang thư theo, nên mối quan hệ cần rõ ràng và khớp với các câu trả lời khác.'),

('b1b2', 'What is the purpose of your business trip, and who will you be meeting?', 'Mục đích chuyến công tác của anh/chị là gì, và anh/chị sẽ gặp ai?',
 'For B1 business trips, know the company you''re visiting, the names/titles of who you''ll meet, and the specific business activity (contract negotiation, trade show, training, conference). A letter from your Vietnamese employer describing the trip helps.',
 'Đối với chuyến công tác diện B1, hãy biết rõ công ty sẽ đến thăm, tên/chức danh người sẽ gặp, và hoạt động kinh doanh cụ thể (đàm phán hợp đồng, hội chợ thương mại, đào tạo, hội nghị). Thư từ công ty Việt Nam mô tả chuyến đi sẽ giúp ích.'),

('b1b2', 'Are you married? Do you have children? Will they stay in Vietnam while you travel?', 'Anh/chị đã kết hôn chưa? Có con không? Họ có ở lại Việt Nam trong khi anh/chị đi không?',
 'Family remaining in Vietnam — a spouse, children, or elderly parents you support — is one of the strongest ties an officer looks for. State this clearly and confidently if it applies to you.',
 'Gia đình ở lại Việt Nam — vợ/chồng, con cái, hoặc cha mẹ già mà anh/chị đang chăm sóc — là một trong những ràng buộc mạnh nhất mà viên chức tìm kiếm. Nếu đúng với trường hợp của anh/chị, hãy nêu rõ và tự tin.'),

('b1b2', 'Do you plan to work or study while you are in the United States?', 'Anh/chị có dự định đi làm hoặc đi học trong thời gian ở Mỹ không?',
 'A B1/B2 visa does not permit working or enrolling in a full course of study in the U.S. Answer clearly that you do not plan to — if your real goal involves study or work, you need an F, M, or work visa instead, and saying otherwise here is visa fraud.',
 'Visa B1/B2 không cho phép đi làm hoặc theo học một chương trình học toàn thời gian tại Mỹ. Hãy trả lời rõ ràng là không có dự định đó — nếu mục đích thật sự là học tập hoặc làm việc, anh/chị cần visa F, M, hoặc visa lao động thay vì visa này, và trả lời sai ở đây là gian lận visa.'),

('b1b2', 'Do you have a return flight booked, or how do you plan to depart the United States?', 'Anh/chị đã đặt vé khứ hồi chưa, hoặc dự định rời khỏi Mỹ như thế nào?',
 'A booked or at least planned return date shows a defined trip with a clear end. You don''t always need a ticket purchased before the interview, but you should know your intended return date and be able to describe your plan.',
 'Có vé khứ hồi hoặc ít nhất đã lên kế hoạch ngày về cho thấy đây là một chuyến đi có thời hạn rõ ràng. Anh/chị không nhất thiết phải mua vé trước khi phỏng vấn, nhưng cần biết ngày dự định quay về và mô tả được kế hoạch của mình.'),

('b1b2', 'Have you applied for a U.S. visa before? What was the outcome?', 'Anh/chị đã từng nộp đơn xin visa Mỹ trước đây chưa? Kết quả như thế nào?',
 'Answer honestly and consistently with your DS-160 travel history. If you were approved before and traveled and returned on time, mention that — a clean prior travel record is one of the best things you can point to.',
 'Hãy trả lời trung thực và khớp với lịch sử du lịch đã khai trong DS-160. Nếu trước đây từng được duyệt và đã đi/về đúng hạn, hãy nêu ra — lịch sử du lịch tốt trước đó là một trong những điểm mạnh nhất anh/chị có thể nêu.'),

('b1b2', 'Why did you choose this particular time to visit the United States?', 'Tại sao anh/chị chọn thời điểm này để đến Mỹ?',
 'Tie the timing to something concrete — a relative''s wedding, a specific conference date, school holidays, approved annual leave from work. A specific, verifiable reason for the timing is more convincing than "just because."',
 'Hãy gắn thời điểm với một lý do cụ thể — đám cưới người thân, ngày diễn ra hội nghị, kỳ nghỉ của con, hoặc thời gian nghỉ phép được công ty duyệt. Một lý do cụ thể, có thể kiểm chứng sẽ thuyết phục hơn là "chỉ vì muốn đi".'),

('b1b2', 'What would you do if your visa application were denied?', 'Anh/chị sẽ làm gì nếu đơn xin visa bị từ chối?',
 'Answer calmly — say you would continue your life and work in Vietnam as normal and may reapply in the future if your circumstances change. This reinforces that your life is genuinely centered in Vietnam, not contingent on this visa.',
 'Hãy trả lời bình tĩnh — nói rằng anh/chị sẽ tiếp tục cuộc sống và công việc bình thường ở Việt Nam, và có thể nộp lại đơn trong tương lai nếu hoàn cảnh thay đổi. Điều này củng cố rằng cuộc sống của anh/chị thực sự gắn với Việt Nam, chứ không phụ thuộc vào visa này.');
