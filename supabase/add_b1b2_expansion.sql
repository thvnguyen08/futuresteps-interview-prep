-- One-time migration: expand the B1/B2 visitor visa category and add red-flag
-- and document-checklist content, mirroring the marriage pilot. Run this once
-- in the Supabase SQL editor (Project → SQL Editor → New query).
--
-- ⚠  Run this file exactly once — the INSERTs would duplicate rows if run
--    twice.

-- Ensure the content_type column exists (idempotent; independently runnable).
alter table questions add column if not exists content_type text not null default 'question';
alter table questions drop constraint if exists questions_content_type_check;
alter table questions add constraint questions_content_type_check
  check (content_type in ('question', 'red_flag', 'checklist'));

-- 1. New B1/B2 PRACTICE QUESTIONS (brings the bank from ~20 to ~55). These are
--    consular-interview questions; answer_* holds coaching tips. The recurring
--    themes a visa officer weighs: a clear temporary purpose, ability to fund
--    the trip, and strong ties that guarantee you return to Vietnam.
insert into questions (category, content_type, question_en, question_vi, answer_en, answer_vi) values

('b1b2', 'question', 'What exactly will you do day to day during your visit?', 'Trong chuyến đi, mỗi ngày anh/chị sẽ làm gì cụ thể?',
 'Give a concrete, realistic plan for your trip. Specific activities are more convincing than a vague "traveling and sightseeing."',
 'Hãy đưa ra kế hoạch cụ thể, thực tế cho chuyến đi. Các hoạt động cụ thể thuyết phục hơn câu nói chung chung "đi du lịch, tham quan".'),

('b1b2', 'question', 'Which cities or places do you plan to visit?', 'Anh/chị dự định thăm những thành phố hoặc địa điểm nào?',
 'Name the places on your itinerary. Knowing where you are going shows the trip is real and planned.',
 'Hãy nêu các địa điểm trong lịch trình. Biết mình sẽ đi đâu cho thấy chuyến đi là thật và có kế hoạch.'),

('b1b2', 'question', 'How did you decide on the length of your trip?', 'Anh/chị quyết định thời gian chuyến đi dựa trên điều gì?',
 'Tie the length to your purpose and your obligations at home (work, family). A trip length that fits your life looks credible.',
 'Hãy gắn thời gian chuyến đi với mục đích và trách nhiệm ở quê nhà (công việc, gia đình). Thời gian phù hợp với cuộc sống của anh/chị sẽ đáng tin.'),

('b1b2', 'question', 'Who invited you, and what is the occasion?', 'Ai mời anh/chị, và nhân dịp gì?',
 'If you are visiting for an event (a wedding, graduation, or a new baby), explain who invited you and your relationship to them.',
 'Nếu anh/chị đến dự một sự kiện (đám cưới, tốt nghiệp, hay em bé mới sinh), hãy giải thích ai mời và mối quan hệ của anh/chị với họ.'),

('b1b2', 'question', 'What is your relationship to the person you are visiting?', 'Mối quan hệ của anh/chị với người anh/chị đến thăm là gì?',
 'Describe the relationship clearly and honestly. Be ready to explain their status in the U.S. and that you plan to return home afterward.',
 'Hãy mô tả mối quan hệ rõ ràng và trung thực. Hãy sẵn sàng giải thích tình trạng của họ ở Mỹ và rằng anh/chị dự định quay về sau đó.'),

('b1b2', 'question', 'How will you pay for this trip?', 'Anh/chị sẽ chi trả cho chuyến đi này bằng cách nào?',
 'State clearly whether you fund it from your salary and savings, or someone sponsors you. Be ready to show the money is real and sufficient.',
 'Hãy nêu rõ anh/chị tự chi trả từ lương và tiết kiệm, hay có người tài trợ. Hãy sẵn sàng chứng minh số tiền là thật và đủ.'),

('b1b2', 'question', 'Roughly how much will the whole trip cost, and is your budget enough?', 'Tổng chuyến đi tốn khoảng bao nhiêu, và ngân sách của anh/chị có đủ không?',
 'Have a realistic sense of the total cost and show your funds cover it comfortably. Unrealistic budgets raise doubt.',
 'Hãy nắm được tổng chi phí thực tế và cho thấy tiền của anh/chị đủ trang trải thoải mái. Ngân sách phi thực tế gây nghi ngờ.'),

('b1b2', 'question', 'What is your job title and employer, and how long have you worked there?', 'Chức danh và nơi làm việc của anh/chị là gì, và anh/chị đã làm ở đó bao lâu?',
 'Stable employment is a strong tie to Vietnam. State your role and time with the employer clearly.',
 'Công việc ổn định là một ràng buộc mạnh với Việt Nam. Hãy nêu rõ vị trí và thời gian gắn bó với nơi làm việc.'),

('b1b2', 'question', 'Did your employer approve your leave? Do you have a leave letter?', 'Nơi làm việc có duyệt nghỉ phép cho anh/chị không? Anh/chị có thư cho nghỉ phép không?',
 'Approved leave shows you have a job to return to. Bring a letter from your employer confirming your leave and return date.',
 'Việc được duyệt nghỉ cho thấy anh/chị có công việc để quay về. Hãy mang thư từ nơi làm việc xác nhận thời gian nghỉ và ngày quay lại.'),

('b1b2', 'question', 'What will happen with your job while you are away?', 'Công việc của anh/chị sẽ ra sao trong thời gian đi vắng?',
 'Explain that your position is held for you and you are expected back. This reinforces your intent to return.',
 'Hãy giải thích rằng vị trí của anh/chị được giữ và anh/chị được mong quay lại. Điều này khẳng định ý định trở về.'),

('b1b2', 'question', 'Do you have children, and who will care for them while you travel?', 'Anh/chị có con không, và ai sẽ chăm sóc chúng khi anh/chị đi?',
 'If your children stay in Vietnam, that is a strong tie pulling you home. Explain the care arrangements simply and honestly.',
 'Nếu con anh/chị ở lại Việt Nam, đó là một ràng buộc mạnh kéo anh/chị về. Hãy giải thích việc chăm sóc một cách đơn giản và trung thực.'),

('b1b2', 'question', 'What property or assets do you own in Vietnam?', 'Anh/chị sở hữu nhà đất hoặc tài sản gì ở Việt Nam?',
 'Property, savings, and a business are ties that show you have reasons to return. Mention them and bring documents if you can.',
 'Nhà đất, tiền tiết kiệm, và doanh nghiệp là những ràng buộc cho thấy anh/chị có lý do quay về. Hãy nêu ra và mang giấy tờ nếu có thể.'),

('b1b2', 'question', 'Do you run a business? Who will manage it while you are gone?', 'Anh/chị có kinh doanh không? Ai sẽ quản lý khi anh/chị đi vắng?',
 'A business you must return to is a strong tie. Explain who runs it in your absence and that you will come back to it.',
 'Một doanh nghiệp mà anh/chị phải quay về là ràng buộc mạnh. Hãy giải thích ai điều hành khi anh/chị vắng mặt và rằng anh/chị sẽ trở về với nó.'),

('b1b2', 'question', 'Have you visited the United States before? Did you return on time?', 'Anh/chị đã từng đến Hoa Kỳ chưa? Anh/chị có quay về đúng hạn không?',
 'A clean prior travel record — entering and leaving on time — strongly supports a new application. State it clearly.',
 'Một lịch sử đi lại tốt — nhập cảnh và rời đi đúng hạn — hỗ trợ mạnh cho đơn mới. Hãy nêu rõ điều đó.'),

('b1b2', 'question', 'Which countries have you traveled to recently?', 'Gần đây anh/chị đã đi những nước nào?',
 'Prior international travel with timely returns builds your credibility as a genuine visitor. List your recent trips.',
 'Các chuyến đi nước ngoài trước đây với việc quay về đúng hạn xây dựng độ tin cậy của anh/chị như một khách du lịch thật sự. Hãy liệt kê các chuyến gần đây.'),

('b1b2', 'question', 'Have you ever overstayed a visa in any country?', 'Anh/chị đã từng ở quá hạn visa ở bất kỳ nước nào chưa?',
 'Answer honestly. If there is such history, be ready to explain it; officers often already know, and honesty is essential.',
 'Hãy trả lời trung thực. Nếu có lịch sử như vậy, hãy sẵn sàng giải thích; viên chức thường đã biết, và trung thực là điều thiết yếu.'),

('b1b2', 'question', 'Do you have family members who have immigrated to the United States?', 'Anh/chị có người thân đã định cư ở Hoa Kỳ không?',
 'Answer truthfully. Having immigrant relatives is not disqualifying, but be ready to show it does not change your plan to return.',
 'Hãy trả lời trung thực. Có người thân định cư không khiến bị từ chối, nhưng hãy sẵn sàng cho thấy điều đó không thay đổi kế hoạch quay về của anh/chị.'),

('b1b2', 'question', 'For a business trip: who is your U.S. counterpart and what will you discuss?', 'Với chuyến công tác: đối tác Hoa Kỳ của anh/chị là ai và anh/chị sẽ trao đổi những gì?',
 'Explain the company, the people you''ll meet, and the purpose (meetings, training, a conference). Bring an invitation letter if you have one.',
 'Hãy giải thích công ty, những người anh/chị sẽ gặp, và mục đích (họp, đào tạo, hội nghị). Hãy mang thư mời nếu có.'),

('b1b2', 'question', 'Do you have a return ticket or a travel itinerary?', 'Anh/chị có vé khứ hồi hoặc lịch trình đi lại không?',
 'A round-trip booking and itinerary support a temporary, planned visit. Have them ready to show.',
 'Vé khứ hồi và lịch trình hỗ trợ cho một chuyến thăm tạm thời, có kế hoạch. Hãy chuẩn bị sẵn để trình.'),

('b1b2', 'question', 'Where exactly will you stay — a hotel or with relatives?', 'Anh/chị sẽ ở đâu cụ thể — khách sạn hay ở nhà người thân?',
 'Give the specific place, and if staying with someone, explain your relationship. A concrete answer shows a real plan.',
 'Hãy nêu địa điểm cụ thể, và nếu ở nhà ai đó, hãy giải thích mối quan hệ. Câu trả lời cụ thể cho thấy kế hoạch thật.'),

('b1b2', 'question', 'How much money will you bring or have available for the trip?', 'Anh/chị sẽ mang theo hoặc có sẵn bao nhiêu tiền cho chuyến đi?',
 'Show you have enough funds for your planned length of stay. Be consistent with your bank statements.',
 'Hãy cho thấy anh/chị có đủ tiền cho thời gian dự định ở lại. Hãy nhất quán với sao kê ngân hàng.'),

('b1b2', 'question', 'What is your monthly income and how much do you have in savings?', 'Thu nhập hằng tháng của anh/chị là bao nhiêu và anh/chị có bao nhiêu tiền tiết kiệm?',
 'Steady income and savings demonstrate both funding for the trip and a stable life at home. Answer clearly and truthfully.',
 'Thu nhập đều đặn và tiền tiết kiệm cho thấy vừa có nguồn cho chuyến đi vừa có cuộc sống ổn định ở quê nhà. Hãy trả lời rõ ràng và trung thực.'),

('b1b2', 'question', 'Are you married, and where will your spouse be during your trip?', 'Anh/chị đã kết hôn chưa, và vợ/chồng anh/chị sẽ ở đâu trong chuyến đi?',
 'Family remaining in Vietnam is a strong tie. Explain your family situation and that they expect you back.',
 'Gia đình ở lại Việt Nam là ràng buộc mạnh. Hãy giải thích hoàn cảnh gia đình và rằng họ mong anh/chị trở về.'),

('b1b2', 'question', 'What ties guarantee that you will return to Vietnam?', 'Những ràng buộc nào bảo đảm rằng anh/chị sẽ quay về Việt Nam?',
 'Point to your job, family, property, and responsibilities at home. Strong, specific ties are the single most important factor for approval.',
 'Hãy nêu công việc, gia đình, nhà đất, và trách nhiệm ở quê nhà. Các ràng buộc mạnh, cụ thể là yếu tố quan trọng nhất để được cấp visa.'),

('b1b2', 'question', 'Have you ever been refused entry or removed from any country?', 'Anh/chị đã từng bị từ chối nhập cảnh hoặc bị trục xuất khỏi nước nào chưa?',
 'Disclose any such history honestly. Concealing it is far more damaging than explaining the circumstances.',
 'Hãy khai báo trung thực mọi lịch sử như vậy. Che giấu gây hại hơn nhiều so với giải thích hoàn cảnh.'),

('b1b2', 'question', 'What is your educational background?', 'Nền tảng học vấn của anh/chị là gì?',
 'Summarize your education briefly. It helps the officer understand your profile and your life in Vietnam.',
 'Hãy tóm tắt ngắn gọn quá trình học của anh/chị. Điều này giúp viên chức hiểu hồ sơ và cuộc sống của anh/chị ở Việt Nam.'),

('b1b2', 'question', 'For medical treatment: which hospital and doctor, and how will you pay?', 'Với việc chữa bệnh: bệnh viện và bác sĩ nào, và anh/chị sẽ chi trả ra sao?',
 'If your trip is for medical care, name the hospital, have a doctor''s letter, and show how you will pay the estimated costs.',
 'Nếu chuyến đi để chữa bệnh, hãy nêu tên bệnh viện, có thư của bác sĩ, và cho thấy cách anh/chị sẽ chi trả chi phí ước tính.'),

('b1b2', 'question', 'Do you understand that a visitor visa does not allow you to work in the U.S.?', 'Anh/chị có hiểu rằng visa du lịch không cho phép làm việc ở Mỹ không?',
 'Confirm that you know you cannot work on a B1/B2 visa. Showing you understand and intend to follow the rules builds trust.',
 'Hãy xác nhận rằng anh/chị biết mình không được làm việc với visa B1/B2. Cho thấy anh/chị hiểu và có ý định tuân thủ quy định sẽ tạo niềm tin.'),

('b1b2', 'question', 'Do you intend to work or study while you are in the United States?', 'Anh/chị có ý định làm việc hoặc học tập khi ở Hoa Kỳ không?',
 'The honest answer must be no — a visitor visa is only for tourism, family visits, or short business. Be clear and firm about this.',
 'Câu trả lời trung thực phải là không — visa du lịch chỉ dành cho du lịch, thăm gia đình, hoặc công tác ngắn. Hãy nói rõ và dứt khoát về điều này.'),

('b1b2', 'question', 'How long have you been planning this trip?', 'Anh/chị đã lên kế hoạch cho chuyến đi này bao lâu rồi?',
 'A trip you have thought through over time looks more genuine than a sudden, vague plan. Describe how the plan came together.',
 'Một chuyến đi được suy nghĩ kỹ theo thời gian trông chân thật hơn một kế hoạch đột ngột, mơ hồ. Hãy mô tả kế hoạch đã hình thành ra sao.'),

('b1b2', 'question', 'Who else in your family is traveling with you or staying behind?', 'Còn ai trong gia đình đi cùng anh/chị hoặc ở lại?',
 'Explain who travels and who remains in Vietnam. Family staying home strengthens your ties; be consistent about everyone''s plans.',
 'Hãy giải thích ai đi cùng và ai ở lại Việt Nam. Gia đình ở nhà củng cố ràng buộc của anh/chị; hãy nhất quán về kế hoạch của mọi người.'),

('b1b2', 'question', 'If you enjoy your visit, would you want to stay in the United States?', 'Nếu thấy thích chuyến đi, anh/chị có muốn ở lại Hoa Kỳ không?',
 'This tests immigrant intent. Answer honestly but make clear your life, family, and responsibilities are in Vietnam and you will return.',
 'Câu này kiểm tra ý định định cư. Hãy trả lời trung thực nhưng nói rõ cuộc sống, gia đình, và trách nhiệm của anh/chị ở Việt Nam và anh/chị sẽ quay về.'),

('b1b2', 'question', 'What would you do if your visa were denied today?', 'Anh/chị sẽ làm gì nếu hôm nay visa bị từ chối?',
 'Answer calmly — you would carry on with life in Vietnam and perhaps apply again later. Composure signals you are not desperate to leave.',
 'Hãy trả lời bình tĩnh — anh/chị sẽ tiếp tục cuộc sống ở Việt Nam và có thể nộp lại sau. Sự điềm tĩnh cho thấy anh/chị không cố rời đi bằng mọi giá.'),

('b1b2', 'question', 'Does your visit fit with your work schedule and obligations at home?', 'Chuyến đi có phù hợp với lịch làm việc và trách nhiệm của anh/chị ở quê nhà không?',
 'Showing the trip fits around a job and duties you must return to reinforces that your stay is temporary.',
 'Cho thấy chuyến đi phù hợp với công việc và trách nhiệm mà anh/chị phải quay về khẳng định rằng việc ở lại chỉ là tạm thời.');

-- 2. B1/B2 RED FLAGS.
insert into questions (category, content_type, question_en, question_vi, answer_en, answer_vi) values

('b1b2', 'red_flag', 'Answers that suggest you might not return to Vietnam', 'Câu trả lời cho thấy anh/chị có thể không quay về Việt Nam',
 'The visitor visa is temporary. Any hint that you want to stay, work, or join relatives signals immigrant intent. Keep your answers centered on a short visit and a firm return.',
 'Visa du lịch là tạm thời. Bất kỳ dấu hiệu nào cho thấy anh/chị muốn ở lại, làm việc, hay đoàn tụ với người thân đều thể hiện ý định định cư. Hãy giữ câu trả lời tập trung vào một chuyến thăm ngắn và việc quay về chắc chắn.'),

('b1b2', 'red_flag', 'Weak ties to Vietnam', 'Ràng buộc với Việt Nam yếu',
 'No steady job, property, or family obligations makes officers doubt you''ll return. Emphasize the concrete commitments that pull you home.',
 'Không có công việc ổn định, nhà đất, hay trách nhiệm gia đình khiến viên chức nghi ngờ anh/chị sẽ quay về. Hãy nhấn mạnh những ràng buộc cụ thể kéo anh/chị về nhà.'),

('b1b2', 'red_flag', 'An unclear or inconsistent trip purpose', 'Mục đích chuyến đi không rõ ràng hoặc không nhất quán',
 'A vague or shifting reason for the trip is a major warning sign. Have one clear, simple purpose that matches your DS-160 and your documents.',
 'Một lý do mơ hồ hoặc thay đổi cho chuyến đi là dấu hiệu cảnh báo lớn. Hãy có một mục đích rõ ràng, đơn giản, khớp với DS-160 và giấy tờ của anh/chị.'),

('b1b2', 'red_flag', 'Being unable to explain who pays for the trip', 'Không giải thích được ai chi trả cho chuyến đi',
 'You must clearly show how the trip is funded and that the money is genuine. Confusion about finances undermines the application.',
 'Anh/chị phải cho thấy rõ chuyến đi được tài trợ ra sao và số tiền là thật. Sự lúng túng về tài chính làm suy yếu đơn.'),

('b1b2', 'red_flag', 'Answers that contradict your DS-160', 'Câu trả lời mâu thuẫn với DS-160',
 'The officer has your DS-160 on screen. Make sure what you say about your purpose, funding, and ties matches exactly what you submitted.',
 'Viên chức có DS-160 của anh/chị trên màn hình. Hãy đảm bảo những gì anh/chị nói về mục đích, tài chính, và ràng buộc khớp chính xác với những gì đã nộp.'),

('b1b2', 'red_flag', 'A long or open-ended stay with no justification', 'Thời gian ở lại dài hoặc không xác định mà không có lý do',
 'Requesting a lengthy or vague stay raises concern you may not leave. Keep your planned stay short and tied to a clear purpose.',
 'Xin ở lại lâu hoặc không rõ thời gian gây lo ngại rằng anh/chị có thể không rời đi. Hãy giữ thời gian dự định ngắn và gắn với mục đích rõ ràng.'),

('b1b2', 'red_flag', 'Recently unemployed or newly changed jobs with no strong ties', 'Vừa thất nghiệp hoặc mới đổi việc mà không có ràng buộc mạnh',
 'An unstable work situation weakens your ties. If your circumstances recently changed, emphasize your other ties — family, property, or savings.',
 'Tình trạng công việc bất ổn làm yếu ràng buộc của anh/chị. Nếu hoàn cảnh vừa thay đổi, hãy nhấn mạnh các ràng buộc khác — gia đình, nhà đất, hay tiền tiết kiệm.'),

('b1b2', 'red_flag', 'Relatives in the U.S. plus a plan that looks like joining them', 'Có người thân ở Mỹ cùng kế hoạch trông giống như đến để đoàn tụ',
 'Visiting relatives is fine, but if your answers suggest you intend to stay with them, that reads as immigrant intent. Keep the focus on a short, specific visit.',
 'Thăm người thân là bình thường, nhưng nếu câu trả lời cho thấy anh/chị định ở lại với họ, điều đó bị hiểu là ý định định cư. Hãy giữ trọng tâm vào một chuyến thăm ngắn, cụ thể.'),

('b1b2', 'red_flag', 'Insufficient funds for the trip you describe', 'Không đủ tiền cho chuyến đi mà anh/chị mô tả',
 'If your finances can''t realistically cover the trip, the officer doubts the plan or worries you''ll work illegally. Make sure your funds match your itinerary.',
 'Nếu tài chính của anh/chị không thực sự đủ trang trải chuyến đi, viên chức sẽ nghi ngờ kế hoạch hoặc lo anh/chị sẽ làm việc bất hợp pháp. Hãy đảm bảo tiền của anh/chị khớp với lịch trình.'),

('b1b2', 'red_flag', 'Overstays or visa refusals in your history left unexplained', 'Lịch sử ở quá hạn hoặc bị từ chối visa mà không giải thích',
 'Past overstays or refusals don''t automatically bar you, but ignoring them does harm. Acknowledge your history and explain what has changed.',
 'Việc từng ở quá hạn hoặc bị từ chối không tự động khiến anh/chị bị loại, nhưng phớt lờ chúng thì gây hại. Hãy thừa nhận lịch sử và giải thích điều gì đã thay đổi.'),

('b1b2', 'red_flag', 'Memorized, rehearsed-sounding answers', 'Câu trả lời như học thuộc, được tập dượt',
 'Scripted answers make officers suspicious. Know your real plans and finances well enough to answer naturally and handle follow-up questions.',
 'Câu trả lời như đọc bài khiến viên chức nghi ngờ. Hãy nắm rõ kế hoạch và tài chính thật của mình đủ để trả lời tự nhiên và xử lý các câu hỏi phụ.'),

('b1b2', 'red_flag', 'Nervously over-explaining or volunteering suspicious details', 'Lo lắng giải thích quá nhiều hoặc tự khai ra những chi tiết đáng ngờ',
 'Long, unprompted explanations can create doubt where there was none. Answer the question asked simply and truthfully, then stop.',
 'Những lời giải thích dài dòng không được hỏi có thể tạo ra nghi ngờ vốn không có. Hãy trả lời đúng câu được hỏi một cách đơn giản và trung thực, rồi dừng lại.');

-- 3. B1/B2 DOCUMENT CHECKLIST.
insert into questions (category, content_type, question_en, question_vi, answer_en, answer_vi) values

('b1b2', 'checklist', 'Valid passport (and old passports with prior visas)', 'Hộ chiếu còn hiệu lực (và hộ chiếu cũ có visa trước đây)',
 'Bring your current passport valid at least six months out, plus older passports showing your travel history.',
 'Hãy mang hộ chiếu hiện tại còn hiệu lực ít nhất sáu tháng, cùng các hộ chiếu cũ cho thấy lịch sử đi lại của anh/chị.'),

('b1b2', 'checklist', 'DS-160 confirmation page', 'Trang xác nhận DS-160',
 'Bring the printed confirmation with the barcode — it is required to be interviewed.',
 'Hãy mang trang xác nhận đã in có mã vạch — bắt buộc phải có để được phỏng vấn.'),

('b1b2', 'checklist', 'Visa appointment confirmation', 'Xác nhận lịch hẹn visa',
 'Bring your appointment letter with the date and time of your interview.',
 'Hãy mang thư hẹn có ngày và giờ phỏng vấn của anh/chị.'),

('b1b2', 'checklist', 'Proof of funds — bank statements and savings', 'Bằng chứng tài chính — sao kê ngân hàng và tiết kiệm',
 'Bring recent statements showing enough money to cover your trip. Consistent, steady balances are more convincing than a sudden large deposit.',
 'Hãy mang sao kê gần đây cho thấy đủ tiền trang trải chuyến đi. Số dư ổn định, đều đặn thuyết phục hơn một khoản tiền lớn gửi vào đột ngột.'),

('b1b2', 'checklist', 'Employment letter with position, salary, and approved leave', 'Thư xác nhận việc làm nêu chức vụ, lương, và việc được duyệt nghỉ',
 'A letter confirming your job, salary, and approved leave with a return date is strong evidence you will come back.',
 'Một thư xác nhận công việc, lương, và việc được duyệt nghỉ kèm ngày quay lại là bằng chứng mạnh cho thấy anh/chị sẽ trở về.'),

('b1b2', 'checklist', 'Business registration or pay slips if self-employed', 'Giấy phép kinh doanh hoặc phiếu lương nếu tự kinh doanh',
 'If you own a business, bring registration papers and financial records; if employed, bring recent pay slips.',
 'Nếu anh/chị có doanh nghiệp, hãy mang giấy phép và hồ sơ tài chính; nếu đi làm công, hãy mang phiếu lương gần đây.'),

('b1b2', 'checklist', 'Property ownership documents', 'Giấy tờ sở hữu nhà đất',
 'Land or home ownership papers demonstrate strong ties to Vietnam and reasons to return.',
 'Giấy tờ sở hữu đất hoặc nhà cho thấy ràng buộc mạnh với Việt Nam và lý do quay về.'),

('b1b2', 'checklist', 'Evidence of family ties in Vietnam', 'Bằng chứng ràng buộc gia đình ở Việt Nam',
 'Marriage and birth certificates or household registration show family who expect you back home.',
 'Giấy kết hôn và giấy khai sinh hoặc sổ hộ khẩu cho thấy gia đình mong anh/chị trở về.'),

('b1b2', 'checklist', 'Invitation letter from your U.S. host, if any', 'Thư mời từ người bảo lãnh ở Mỹ, nếu có',
 'If visiting someone, bring their invitation letter, proof of their status, and your relationship to them.',
 'Nếu đến thăm ai đó, hãy mang thư mời của họ, bằng chứng về tình trạng của họ, và mối quan hệ của anh/chị với họ.'),

('b1b2', 'checklist', 'Travel itinerary and return ticket', 'Lịch trình đi lại và vé khứ hồi',
 'A round-trip booking and day-by-day itinerary show a planned, temporary visit.',
 'Vé khứ hồi và lịch trình theo từng ngày cho thấy một chuyến thăm có kế hoạch và tạm thời.'),

('b1b2', 'checklist', 'Hotel bookings or accommodation details', 'Đặt phòng khách sạn hoặc thông tin nơi ở',
 'Bring confirmation of where you will stay, whether a hotel reservation or a relative''s address.',
 'Hãy mang xác nhận nơi anh/chị sẽ ở, dù là đặt phòng khách sạn hay địa chỉ của người thân.'),

('b1b2', 'checklist', 'For business: invitation and event details', 'Với công tác: thư mời và thông tin sự kiện',
 'For a business trip, bring the U.S. company''s invitation and details of the meetings, training, or conference.',
 'Với chuyến công tác, hãy mang thư mời của công ty Hoa Kỳ và thông tin về các cuộc họp, khóa đào tạo, hay hội nghị.'),

('b1b2', 'checklist', 'For medical trips: doctor''s letter, appointment, and cost/payment proof', 'Với chuyến chữa bệnh: thư bác sĩ, lịch hẹn, và bằng chứng chi phí/thanh toán',
 'If traveling for treatment, bring the hospital appointment, a doctor''s letter, and proof you can pay the estimated costs.',
 'Nếu đi chữa bệnh, hãy mang lịch hẹn bệnh viện, thư của bác sĩ, và bằng chứng anh/chị có thể chi trả chi phí ước tính.'),

('b1b2', 'checklist', 'Originals plus copies, organized', 'Bản gốc kèm bản sao, sắp xếp gọn gàng',
 'Bring originals for the officer to see and copies to hand over, organized so you can find any document quickly.',
 'Hãy mang bản gốc để viên chức xem và bản sao để nộp, sắp xếp gọn để anh/chị tìm được bất kỳ giấy tờ nào nhanh chóng.');
