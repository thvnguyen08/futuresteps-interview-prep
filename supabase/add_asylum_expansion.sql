-- One-time migration: expand the asylum category and add red-flag and
-- document-checklist content, mirroring the marriage pilot. Run this once in
-- the Supabase SQL editor (Project → SQL Editor → New query).
--
-- ⚠  Run this file exactly once — the INSERTs would duplicate rows if run
--    twice.

-- Ensure the content_type column exists (added by add_marriage_expansion.sql;
-- repeated here so this file is independently runnable). Idempotent.
alter table questions add column if not exists content_type text not null default 'question';
alter table questions drop constraint if exists questions_content_type_check;
alter table questions add constraint questions_content_type_check
  check (content_type in ('question', 'red_flag', 'checklist'));

-- 1. New asylum PRACTICE QUESTIONS (brings the bank from ~19 to ~55). These are
--    testimony questions with no single correct answer; answer_* holds coaching
--    tips. The recurring theme: tell the truth, be specific, and stay
--    consistent with your written Form I-589 declaration.
insert into questions (category, content_type, question_en, question_vi, answer_en, answer_vi) values

('asylum', 'question', 'Describe the most serious incident that happened to you, with the date and place.', 'Hãy mô tả sự việc nghiêm trọng nhất đã xảy ra với anh/chị, kèm ngày tháng và địa điểm.',
 'Give specific details — when, where, who was involved, and what exactly happened. Specific, consistent detail is what makes testimony credible.',
 'Hãy nêu chi tiết cụ thể — khi nào, ở đâu, ai liên quan, và chính xác điều gì đã xảy ra. Chi tiết cụ thể, nhất quán là điều làm lời khai đáng tin.'),

('asylum', 'question', 'How many times were you harmed or threatened, and over what period of time?', 'Anh/chị bị làm hại hoặc đe dọa bao nhiêu lần, và trong khoảng thời gian nào?',
 'Answer as accurately as you can. If you cannot recall an exact number, say approximately, but keep it consistent with your written statement.',
 'Hãy trả lời chính xác nhất có thể. Nếu không nhớ con số chính xác, hãy nói ước chừng, nhưng phải khớp với lời khai bằng văn bản.'),

('asylum', 'question', 'Who were the people that harmed or threatened you — the government, police, military, or a group?', 'Những người làm hại hoặc đe dọa anh/chị là ai — chính quyền, cảnh sát, quân đội, hay một nhóm nào đó?',
 'Identify your persecutors as clearly as you can. Whether the harm came from the government or from a group the government cannot or will not control is central to your claim.',
 'Hãy xác định rõ nhất có thể những kẻ ngược đãi anh/chị. Việc sự tổn hại đến từ chính quyền hay từ một nhóm mà chính quyền không thể hoặc không muốn kiểm soát là điểm cốt lõi của hồ sơ.'),

('asylum', 'question', 'Why do you believe you were targeted specifically?', 'Vì sao anh/chị tin rằng mình bị nhắm đến một cách cụ thể?',
 'Connect the harm to a protected ground — your race, religion, nationality, political opinion, or membership in a particular social group. Explain how the persecutors knew.',
 'Hãy liên hệ sự tổn hại với một căn cứ được bảo vệ — chủng tộc, tôn giáo, quốc tịch, quan điểm chính trị, hoặc thành viên của một nhóm xã hội cụ thể. Hãy giải thích vì sao kẻ ngược đãi biết được điều đó.'),

('asylum', 'question', 'What is your religion, ethnicity, or political opinion, and how did the persecutors know?', 'Tôn giáo, dân tộc, hoặc quan điểm chính trị của anh/chị là gì, và làm sao kẻ ngược đãi biết được?',
 'Explain your identity or beliefs and how they became known — through activities, membership, public actions, or others reporting you.',
 'Hãy giải thích danh tính hoặc niềm tin của anh/chị và cách chúng bị biết đến — qua hoạt động, việc là thành viên, hành động công khai, hoặc do người khác tố giác.'),

('asylum', 'question', 'Were you ever a member of a political party, religious group, or organization? Which one?', 'Anh/chị đã từng là thành viên của một đảng phái chính trị, nhóm tôn giáo, hoặc tổ chức nào chưa? Tổ chức nào?',
 'Name the group and your role honestly. If you have membership documents, mention that you can provide them.',
 'Hãy nêu tên tổ chức và vai trò của anh/chị một cách trung thực. Nếu có giấy tờ chứng minh là thành viên, hãy nói rằng anh/chị có thể cung cấp.'),

('asylum', 'question', 'Did you take part in any protests, activities, or public actions? Describe them.', 'Anh/chị có tham gia biểu tình, hoạt động, hay hành động công khai nào không? Hãy mô tả.',
 'Describe what you did, when, and where. These details help establish why you drew the attention of your persecutors.',
 'Hãy mô tả anh/chị đã làm gì, khi nào, và ở đâu. Những chi tiết này giúp chứng minh vì sao anh/chị bị kẻ ngược đãi để ý.'),

('asylum', 'question', 'What injuries did you suffer, and did you receive any medical care?', 'Anh/chị bị thương như thế nào, và có được chăm sóc y tế không?',
 'Describe any injuries truthfully and whether you were treated. Medical or hospital records, if you have them, are strong supporting evidence.',
 'Hãy mô tả các thương tích một cách trung thực và việc anh/chị có được điều trị hay không. Hồ sơ y tế hoặc bệnh viện, nếu có, là bằng chứng hỗ trợ mạnh.'),

('asylum', 'question', 'Did anyone witness what happened to you? Who?', 'Có ai chứng kiến điều đã xảy ra với anh/chị không? Là ai?',
 'Name witnesses if there were any. A written statement from a witness can corroborate your account.',
 'Hãy nêu tên nhân chứng nếu có. Một bản khai từ nhân chứng có thể xác nhận cho lời kể của anh/chị.'),

('asylum', 'question', 'Why were the authorities in your country unable or unwilling to protect you?', 'Vì sao chính quyền ở nước anh/chị không thể hoặc không muốn bảo vệ anh/chị?',
 'Explain what happened when you sought help, or why seeking help was pointless or dangerous. This shows the government could not protect you.',
 'Hãy giải thích điều gì đã xảy ra khi anh/chị tìm sự giúp đỡ, hoặc vì sao việc tìm giúp đỡ là vô ích hay nguy hiểm. Điều này cho thấy chính quyền không thể bảo vệ anh/chị.'),

('asylum', 'question', 'Did you try to move to another part of your country before leaving? What happened?', 'Trước khi rời đi, anh/chị có thử chuyển đến vùng khác trong nước không? Điều gì đã xảy ra?',
 'If you tried to relocate internally, explain why it did not keep you safe. This addresses whether you could have avoided harm by moving.',
 'Nếu anh/chị đã thử chuyển vùng trong nước, hãy giải thích vì sao điều đó không giúp anh/chị an toàn. Điều này trả lời cho câu hỏi liệu anh/chị có thể tránh tổn hại bằng cách chuyển đi hay không.'),

('asylum', 'question', 'Have the threats or danger continued after you left? How do you know?', 'Sau khi anh/chị rời đi, các đe dọa hoặc nguy hiểm có tiếp tục không? Làm sao anh/chị biết?',
 'Share how you know the danger continues — messages, family reports, ongoing conditions. This supports your fear of returning.',
 'Hãy chia sẻ làm sao anh/chị biết nguy hiểm vẫn tiếp diễn — tin nhắn, thông tin từ gia đình, tình hình đang diễn ra. Điều này củng cố nỗi sợ khi phải quay về.'),

('asylum', 'question', 'What happened to family members who stayed behind?', 'Điều gì đã xảy ra với những người thân ở lại?',
 'Describe any harm or threats your family faced after you left. Harm to relatives can support that the danger to you is real.',
 'Hãy mô tả những tổn hại hoặc đe dọa mà gia đình anh/chị gặp phải sau khi anh/chị rời đi. Tổn hại với người thân có thể chứng minh nguy hiểm với anh/chị là có thật.'),

('asylum', 'question', 'How did you obtain your passport and travel documents to leave?', 'Anh/chị đã lấy hộ chiếu và giấy tờ đi lại để rời đi bằng cách nào?',
 'Explain honestly how you got your documents, even if the circumstances were difficult. Consistency with your travel history matters.',
 'Hãy giải thích trung thực cách anh/chị có được giấy tờ, dù hoàn cảnh khó khăn. Sự nhất quán với lịch sử đi lại là quan trọng.'),

('asylum', 'question', 'What countries did you pass through on the way to the United States, and how long were you in each?', 'Trên đường đến Hoa Kỳ, anh/chị đã đi qua những nước nào, và ở mỗi nước bao lâu?',
 'List your route and timing. Be ready to explain why you did not settle or seek protection in a country you passed through.',
 'Hãy liệt kê hành trình và thời gian. Hãy sẵn sàng giải thích vì sao anh/chị không định cư hoặc xin bảo vệ ở một nước đã đi qua.'),

('asylum', 'question', 'Did you have legal status or the chance to seek protection in any country you passed through?', 'Anh/chị có tình trạng hợp pháp hoặc cơ hội xin bảo vệ ở bất kỳ nước nào đã đi qua không?',
 'Answer truthfully. If you could have sought protection elsewhere, explain why you did not — this addresses the "firm resettlement" and transit-country concerns.',
 'Hãy trả lời trung thực. Nếu anh/chị có thể xin bảo vệ ở nơi khác, hãy giải thích vì sao không — điều này liên quan đến vấn đề "định cư ổn định" và nước quá cảnh.'),

('asylum', 'question', 'When exactly did you enter the United States, and how — with a visa, at a port of entry, or at the border?', 'Anh/chị nhập cảnh Hoa Kỳ chính xác khi nào, và bằng cách nào — bằng visa, tại cửa khẩu, hay tại biên giới?',
 'Give the date and manner of entry consistent with your records (I-94, visa, or entry documents). This ties to your one-year filing deadline.',
 'Hãy nêu ngày và cách nhập cảnh khớp với hồ sơ của anh/chị (I-94, visa, hoặc giấy tờ nhập cảnh). Điều này liên quan đến thời hạn nộp đơn trong một năm.'),

('asylum', 'question', 'What immigration status, if any, did you have when you entered?', 'Khi nhập cảnh, anh/chị có tình trạng di trú nào không?',
 'State your status at entry honestly (a visa, parole, or entering without inspection). It should match your application and records.',
 'Hãy nêu trung thực tình trạng của anh/chị khi nhập cảnh (visa, được tạm tha, hay nhập cảnh không qua kiểm tra). Nó phải khớp với đơn và hồ sơ của anh/chị.'),

('asylum', 'question', 'Have you traveled outside the United States since you filed for asylum?', 'Từ khi nộp đơn xin tị nạn, anh/chị có ra khỏi Hoa Kỳ không?',
 'Answer honestly. Travel — especially back to your home country — can seriously undermine a fear-based claim, so be ready to explain any trips.',
 'Hãy trả lời trung thực. Việc đi lại — nhất là quay về nước — có thể làm suy yếu nghiêm trọng một hồ sơ dựa trên nỗi sợ, nên hãy sẵn sàng giải thích mọi chuyến đi.'),

('asylum', 'question', 'What documents do you have to prove your identity and nationality?', 'Anh/chị có những giấy tờ nào để chứng minh danh tính và quốc tịch?',
 'Mention your passport, national ID, birth certificate, or similar. Establishing who you are and where you are from is a basic part of the case.',
 'Hãy nêu hộ chiếu, chứng minh nhân dân, giấy khai sinh, hoặc giấy tờ tương tự. Xác định anh/chị là ai và đến từ đâu là phần cơ bản của hồ sơ.'),

('asylum', 'question', 'Do you have country-condition evidence, such as news reports or human rights reports?', 'Anh/chị có bằng chứng về tình hình đất nước, như bản tin báo chí hay báo cáo nhân quyền không?',
 'These reports show the general dangers in your country and support your personal account. Bring copies if you have them.',
 'Những báo cáo này cho thấy các mối nguy chung ở nước anh/chị và hỗ trợ cho lời kể cá nhân. Hãy mang bản sao nếu có.'),

('asylum', 'question', 'Does your testimony today match what you wrote in your Form I-589 declaration?', 'Lời khai hôm nay của anh/chị có khớp với những gì đã viết trong bản tường trình Mẫu I-589 không?',
 'Review your declaration beforehand so your spoken account lines up with it. Contradictions between the two are a leading reason claims are doubted.',
 'Hãy xem lại bản tường trình trước để lời khai bằng miệng khớp với nó. Mâu thuẫn giữa hai bên là lý do hàng đầu khiến hồ sơ bị nghi ngờ.'),

('asylum', 'question', 'Is there anything in your application you need to correct or update?', 'Có điều gì trong đơn của anh/chị cần sửa hoặc cập nhật không?',
 'If something changed or an earlier detail was wrong, say so at the start. Voluntarily correcting an error is far better than being caught in one.',
 'Nếu có điều gì thay đổi hoặc một chi tiết trước đó sai, hãy nói ngay từ đầu. Tự nguyện sửa lỗi tốt hơn nhiều so với bị phát hiện.'),

('asylum', 'question', 'Have you ever been arrested or charged with a crime in the United States or any other country?', 'Anh/chị đã từng bị bắt hoặc bị buộc tội ở Hoa Kỳ hay bất kỳ nước nào khác chưa?',
 'Disclose any criminal history truthfully. Some offenses can bar asylum, and hiding them is far more damaging than explaining them.',
 'Hãy khai báo trung thực mọi tiền án tiền sự. Một số tội có thể khiến bị từ chối tị nạn, và việc giấu giếm gây hại hơn nhiều so với giải thích.'),

('asylum', 'question', 'Have you ever harmed anyone else, or helped a group that harmed others?', 'Anh/chị đã từng làm hại người khác, hoặc giúp đỡ một nhóm gây hại cho người khác chưa?',
 'Answer honestly — this addresses the bars to asylum. If a difficult situation applies to you, it is better to explain it fully with your attorney''s help.',
 'Hãy trả lời trung thực — câu này liên quan đến các trường hợp bị cấm xin tị nạn. Nếu anh/chị rơi vào tình huống khó, tốt hơn hết là giải thích đầy đủ với sự giúp đỡ của luật sư.'),

('asylum', 'question', 'What is your current address and living situation in the United States?', 'Địa chỉ hiện tại và tình trạng sinh sống của anh/chị ở Hoa Kỳ là gì?',
 'Give your current address and who you live with. Keep your address updated with the court or asylum office so you never miss a notice.',
 'Hãy nêu địa chỉ hiện tại và anh/chị sống với ai. Hãy luôn cập nhật địa chỉ với tòa hoặc văn phòng tị nạn để không bỏ lỡ thông báo nào.'),

('asylum', 'question', 'How are you supporting yourself while your case is pending?', 'Anh/chị tự trang trải cuộc sống bằng cách nào trong khi hồ sơ đang chờ giải quyết?',
 'Explain your situation truthfully — work authorization, family support, or savings. There is no penalty for an honest answer.',
 'Hãy giải thích trung thực hoàn cảnh của anh/chị — giấy phép làm việc, sự hỗ trợ của gia đình, hay tiền tiết kiệm. Không có gì bất lợi khi trả lời trung thực.'),

('asylum', 'question', 'Do you understand that you are testifying under oath and must tell the truth today?', 'Anh/chị có hiểu rằng mình đang khai dưới lời tuyên thệ và phải nói sự thật hôm nay không?',
 'Say yes and mean it. Everything you say is under oath; honesty throughout the interview is the foundation of a credible claim.',
 'Hãy nói có và thực hiện đúng như vậy. Mọi điều anh/chị nói đều dưới lời tuyên thệ; sự trung thực suốt buổi phỏng vấn là nền tảng của một hồ sơ đáng tin.'),

('asylum', 'question', 'If your documents are in another language, do you have certified English translations?', 'Nếu giấy tờ của anh/chị bằng ngôn ngữ khác, anh/chị có bản dịch tiếng Anh được chứng thực không?',
 'Every foreign-language document must have a certified English translation. Prepare these in advance so your evidence can be accepted.',
 'Mọi giấy tờ bằng ngôn ngữ nước ngoài phải có bản dịch tiếng Anh được chứng thực. Hãy chuẩn bị sẵn để bằng chứng của anh/chị được chấp nhận.'),

('asylum', 'question', 'Have you had enough time to review your application with your attorney and interpreter?', 'Anh/chị đã có đủ thời gian xem lại đơn cùng luật sư và thông dịch viên chưa?',
 'Review your full application before the interview. Knowing your own story and evidence well helps you answer calmly and consistently.',
 'Hãy xem lại toàn bộ đơn trước buổi phỏng vấn. Nắm rõ câu chuyện và bằng chứng của chính mình giúp anh/chị trả lời bình tĩnh và nhất quán.'),

('asylum', 'question', 'Is the interpreter today translating everything accurately for you?', 'Hôm nay thông dịch viên có dịch mọi thứ chính xác cho anh/chị không?',
 'If you do not understand something or a translation seems wrong, say so immediately. It is important that the record reflects what you truly mean.',
 'Nếu anh/chị không hiểu điều gì hoặc bản dịch có vẻ sai, hãy nói ngay lập tức. Điều quan trọng là biên bản phản ánh đúng ý anh/chị.'),

('asylum', 'question', 'Why is your fear of returning still real today, not only in the past?', 'Vì sao nỗi sợ quay về của anh/chị vẫn là thật cho đến hôm nay, không chỉ trong quá khứ?',
 'Explain why the danger remains — the same people, the same conditions, ongoing threats. Asylum is about a well-founded fear going forward.',
 'Hãy giải thích vì sao nguy hiểm vẫn còn — vẫn những người đó, vẫn tình hình đó, các đe dọa đang tiếp diễn. Tị nạn dựa trên nỗi sợ có căn cứ về tương lai.'),

('asylum', 'question', 'Have you sought asylum or protection in any country other than the United States?', 'Anh/chị đã xin tị nạn hoặc bảo vệ ở bất kỳ nước nào ngoài Hoa Kỳ chưa?',
 'Disclose any prior applications. Whether another country offered you protection can affect your eligibility, so be complete and honest.',
 'Hãy khai báo mọi đơn xin trước đây. Việc một nước khác đã cho anh/chị sự bảo vệ hay chưa có thể ảnh hưởng đến điều kiện, nên hãy đầy đủ và trung thực.'),

('asylum', 'question', 'Can you describe your daily life or work before the persecution began?', 'Anh/chị có thể mô tả cuộc sống hoặc công việc thường ngày trước khi bị ngược đãi không?',
 'Background details make your story real and human. Describe who you were and how the persecution changed your life.',
 'Những chi tiết về hoàn cảnh làm câu chuyện của anh/chị chân thật và sống động. Hãy mô tả anh/chị từng là ai và sự ngược đãi đã thay đổi cuộc đời anh/chị ra sao.'),

('asylum', 'question', 'Who are the family members you want to include in your application, and where are they now?', 'Những người thân nào anh/chị muốn đưa vào đơn, và hiện họ đang ở đâu?',
 'A spouse and unmarried children under 21 in the U.S. can often be included. Have their names, dates of birth, and documents ready.',
 'Vợ/chồng và con chưa kết hôn dưới 21 tuổi ở Hoa Kỳ thường có thể được đưa vào đơn. Hãy chuẩn bị sẵn tên, ngày sinh, và giấy tờ của họ.'),

('asylum', 'question', 'Is there anything important about your case that you have not been asked but want the officer to know?', 'Có điều gì quan trọng về hồ sơ mà anh/chị chưa được hỏi nhưng muốn viên chức biết không?',
 'Interviews often end with this chance. Prepare one or two key points you don''t want to leave out, and share them calmly.',
 'Buổi phỏng vấn thường kết thúc bằng cơ hội này. Hãy chuẩn bị một hai điểm quan trọng mà anh/chị không muốn bỏ sót, và trình bày bình tĩnh.');

-- 2. Asylum RED FLAGS.
insert into questions (category, content_type, question_en, question_vi, answer_en, answer_vi) values

('asylum', 'red_flag', 'Testimony that contradicts your written I-589 declaration', 'Lời khai mâu thuẫn với bản tường trình I-589 đã viết',
 'Officers compare your spoken answers to your written statement line by line. Review your declaration beforehand and, if something was mistaken, correct it openly rather than letting a contradiction surface.',
 'Viên chức so sánh lời khai miệng với bản tường trình viết của anh/chị từng dòng. Hãy xem lại bản tường trình trước, và nếu có gì sai, hãy sửa công khai thay vì để mâu thuẫn lộ ra.'),

('asylum', 'red_flag', 'Vague answers with no dates, places, or specific details', 'Câu trả lời mơ hồ, không có ngày tháng, địa điểm, hay chi tiết cụ thể',
 'Generic statements like "they threatened me" are weak. Credible testimony includes specifics — when, where, who, and what happened. Prepare the concrete details of each key event.',
 'Những câu chung chung như "họ đe dọa tôi" là yếu. Lời khai đáng tin cần chi tiết cụ thể — khi nào, ở đâu, ai, và điều gì đã xảy ra. Hãy chuẩn bị các chi tiết cụ thể của từng sự việc quan trọng.'),

('asylum', 'red_flag', 'Filing after the one-year deadline with no valid exception', 'Nộp đơn sau thời hạn một năm mà không có ngoại lệ hợp lệ',
 'Asylum generally must be filed within one year of arrival. If you filed late, be ready to explain a qualifying exception (changed or extraordinary circumstances) clearly.',
 'Đơn tị nạn thường phải nộp trong vòng một năm kể từ khi đến. Nếu nộp trễ, hãy sẵn sàng giải thích rõ một ngoại lệ hợp lệ (hoàn cảnh thay đổi hoặc bất thường).'),

('asylum', 'red_flag', 'Returning to your home country after claiming fear of it', 'Quay về nước sau khi khai rằng sợ hãi nước đó',
 'Trips back to the country you fear strongly undermine your claim. If you traveled back for an unavoidable reason, be prepared to explain it honestly and in detail.',
 'Các chuyến quay về nước mà anh/chị nói là sợ hãi sẽ làm suy yếu mạnh hồ sơ. Nếu anh/chị quay về vì lý do bất khả kháng, hãy sẵn sàng giải thích trung thực và chi tiết.'),

('asylum', 'red_flag', 'Passing through safe countries without seeking protection', 'Đi qua các nước an toàn mà không xin bảo vệ',
 'Officers ask why you did not seek protection in a country you passed through. Be ready to explain why that was not a real option for you.',
 'Viên chức sẽ hỏi vì sao anh/chị không xin bảo vệ ở nước đã đi qua. Hãy sẵn sàng giải thích vì sao đó không phải là lựa chọn thực sự với anh/chị.'),

('asylum', 'red_flag', 'A story that changes each time you are asked', 'Câu chuyện thay đổi mỗi lần được hỏi',
 'Shifting details signal fabrication to an officer. You cannot memorize a false story perfectly — the answer is to tell the truth, which stays consistent naturally.',
 'Chi tiết thay đổi khiến viên chức nghĩ là bịa đặt. Anh/chị không thể học thuộc một câu chuyện giả một cách hoàn hảo — cách duy nhất là nói sự thật, vốn tự nhiên nhất quán.'),

('asylum', 'red_flag', 'No corroborating evidence when it could reasonably be obtained', 'Không có bằng chứng hỗ trợ trong khi lẽ ra có thể có được',
 'Where evidence is reasonably available — medical records, membership papers, letters — its absence can hurt you. Gather what you realistically can to back up your account.',
 'Khi bằng chứng lẽ ra có thể có được — hồ sơ y tế, giấy tờ thành viên, thư từ — việc thiếu nó có thể gây bất lợi. Hãy thu thập những gì thực tế có thể để chứng minh lời kể.'),

('asylum', 'red_flag', 'Memorized or coached-sounding testimony', 'Lời khai nghe như học thuộc hoặc được mớm',
 'Rehearsed, word-for-word answers make officers suspect the account isn''t your own. Know your real story deeply and tell it naturally, in your own words.',
 'Câu trả lời như đọc thuộc từng chữ khiến viên chức nghi ngờ đó không phải chuyện của chính anh/chị. Hãy nắm thật kỹ câu chuyện thật và kể tự nhiên bằng lời của mình.'),

('asylum', 'red_flag', 'Undisclosed criminal history or a bar to asylum', 'Không khai báo tiền án hoặc yếu tố khiến bị cấm tị nạn',
 'Certain crimes or activities bar asylum, and officers often already have information. Disclose issues to your attorney early so they can be addressed properly rather than discovered.',
 'Một số tội hoặc hành vi khiến bị cấm tị nạn, và viên chức thường đã có thông tin. Hãy khai báo các vấn đề với luật sư sớm để được xử lý đúng cách thay vì bị phát hiện.'),

('asylum', 'red_flag', 'Claiming general hardship rather than targeted persecution', 'Nêu khó khăn chung chung thay vì sự ngược đãi nhắm vào cá nhân',
 'Poverty, crime, or war affecting everyone is usually not enough. You must show harm tied to your race, religion, nationality, political opinion, or social group. Make that connection clear.',
 'Nghèo đói, tội phạm, hay chiến tranh ảnh hưởng đến mọi người thường là chưa đủ. Anh/chị phải chứng minh tổn hại gắn với chủng tộc, tôn giáo, quốc tịch, quan điểm chính trị, hoặc nhóm xã hội của mình. Hãy làm rõ mối liên hệ đó.'),

('asylum', 'red_flag', 'Unexplained gaps between the harm and when you left', 'Khoảng trống không giải thích được giữa lúc bị hại và lúc rời đi',
 'A long delay between the persecution and your departure invites questions about your fear. Be ready to explain what kept you there and why you finally left.',
 'Khoảng thời gian dài giữa lúc bị ngược đãi và lúc anh/chị rời đi khiến người ta nghi ngờ nỗi sợ. Hãy sẵn sàng giải thích điều gì đã giữ anh/chị ở lại và vì sao cuối cùng anh/chị rời đi.'),

('asylum', 'red_flag', 'Letting fear or nerves turn into guessing or exaggeration', 'Để sợ hãi hoặc lo lắng dẫn đến đoán bừa hoặc phóng đại',
 'Under stress, some applicants exaggerate or guess to fill gaps — which creates contradictions. It is fine to say "I don''t remember." Stay calm and stick to what you actually know.',
 'Dưới áp lực, một số người phóng đại hoặc đoán để lấp chỗ trống — điều này tạo ra mâu thuẫn. Nói "Tôi không nhớ" là hoàn toàn được. Hãy bình tĩnh và chỉ nói những gì anh/chị thật sự biết.');

-- 3. Asylum DOCUMENT CHECKLIST.
insert into questions (category, content_type, question_en, question_vi, answer_en, answer_vi) values

('asylum', 'checklist', 'Photo identification and passport', 'Giấy tờ tùy thân có ảnh và hộ chiếu',
 'Bring your passport and any national ID. Establishing your identity and nationality is a basic first step.',
 'Hãy mang hộ chiếu và bất kỳ giấy tờ tùy thân quốc gia nào. Xác định danh tính và quốc tịch là bước đầu cơ bản.'),

('asylum', 'checklist', 'A copy of your filed Form I-589', 'Một bản sao Mẫu I-589 đã nộp',
 'Bring the application you filed so you can review it and stay consistent. Your testimony should match it.',
 'Hãy mang đơn anh/chị đã nộp để có thể xem lại và giữ nhất quán. Lời khai của anh/chị phải khớp với nó.'),

('asylum', 'checklist', 'Your written declaration or personal statement', 'Bản tường trình hoặc lời khai cá nhân bằng văn bản',
 'This is the detailed story of your persecution. Reread it before the interview so your spoken account lines up.',
 'Đây là câu chuyện chi tiết về việc anh/chị bị ngược đãi. Hãy đọc lại trước buổi phỏng vấn để lời khai miệng khớp với nó.'),

('asylum', 'checklist', 'Your interview or hearing notice', 'Thư hẹn phỏng vấn hoặc phiên điều trần',
 'Bring the official notice with the date, time, and location. You may need it to check in.',
 'Hãy mang thư hẹn chính thức có ngày, giờ, và địa điểm. Anh/chị có thể cần nó để làm thủ tục.'),

('asylum', 'checklist', 'Identity and nationality documents', 'Giấy tờ chứng minh danh tính và quốc tịch',
 'Birth certificate, national ID card, household registration, or similar documents help prove who you are and where you are from.',
 'Giấy khai sinh, chứng minh nhân dân, sổ hộ khẩu, hoặc giấy tờ tương tự giúp chứng minh anh/chị là ai và đến từ đâu.'),

('asylum', 'checklist', 'Evidence of the persecution you suffered', 'Bằng chứng về sự ngược đãi mà anh/chị đã chịu',
 'Police reports, medical or hospital records, threat letters, or court documents directly support your account. Bring whatever you have.',
 'Biên bản cảnh sát, hồ sơ y tế hoặc bệnh viện, thư đe dọa, hay giấy tờ tòa án trực tiếp hỗ trợ lời kể của anh/chị. Hãy mang bất cứ thứ gì anh/chị có.'),

('asylum', 'checklist', 'Photographs of injuries or events, if any', 'Ảnh chụp thương tích hoặc sự kiện, nếu có',
 'Photos of injuries, damage, or events can corroborate specific incidents in your story.',
 'Ảnh chụp thương tích, thiệt hại, hoặc sự kiện có thể xác nhận cho các sự việc cụ thể trong câu chuyện của anh/chị.'),

('asylum', 'checklist', 'Country condition evidence', 'Bằng chứng về tình hình đất nước',
 'Human rights reports and credible news articles about your country show the broader dangers behind your personal claim.',
 'Báo cáo nhân quyền và các bài báo đáng tin về nước anh/chị cho thấy các mối nguy rộng hơn đằng sau hồ sơ cá nhân.'),

('asylum', 'checklist', 'Witness affidavits or letters of support', 'Bản khai của nhân chứng hoặc thư xác nhận',
 'Signed statements from people who witnessed events or know your situation add corroboration. Include their contact information.',
 'Bản khai có chữ ký từ những người chứng kiến sự việc hoặc biết hoàn cảnh của anh/chị sẽ củng cố hồ sơ. Hãy kèm thông tin liên lạc của họ.'),

('asylum', 'checklist', 'Membership or affiliation documents', 'Giấy tờ chứng minh là thành viên hoặc liên kết',
 'Party cards, church letters, or organization records help prove the protected ground behind your persecution.',
 'Thẻ đảng, thư của nhà thờ, hoặc hồ sơ tổ chức giúp chứng minh căn cứ được bảo vệ đằng sau việc anh/chị bị ngược đãi.'),

('asylum', 'checklist', 'Certified English translations of foreign documents', 'Bản dịch tiếng Anh được chứng thực cho giấy tờ nước ngoài',
 'Every non-English document needs a certified translation to be accepted. Prepare these ahead of time.',
 'Mọi giấy tờ không phải tiếng Anh cần bản dịch được chứng thực để được chấp nhận. Hãy chuẩn bị trước.'),

('asylum', 'checklist', 'Proof of the date and manner of your U.S. entry', 'Bằng chứng về ngày và cách nhập cảnh Hoa Kỳ',
 'Your I-94, visa, or entry stamp shows when and how you arrived — important for the one-year filing rule.',
 'Mẫu I-94, visa, hoặc dấu nhập cảnh cho thấy anh/chị đến khi nào và bằng cách nào — quan trọng cho quy định nộp đơn trong một năm.'),

('asylum', 'checklist', 'Documents for family members included in your application', 'Giấy tờ cho những người thân được đưa vào đơn',
 'For any spouse or child on your application, bring their identity documents and proof of your relationship (marriage/birth certificates).',
 'Với vợ/chồng hoặc con có trong đơn, hãy mang giấy tờ tùy thân của họ và bằng chứng quan hệ (giấy kết hôn/khai sinh).'),

('asylum', 'checklist', 'Originals plus copies, organized, with your attorney and interpreter arranged', 'Bản gốc kèm bản sao, sắp xếp gọn gàng, cùng luật sư và thông dịch viên đã chuẩn bị',
 'Bring originals and organized copies, and confirm your interpreter (if you need one) and attorney in advance so the interview runs smoothly.',
 'Hãy mang bản gốc và bản sao được sắp xếp, đồng thời sắp xếp trước thông dịch viên (nếu cần) và luật sư để buổi phỏng vấn diễn ra suôn sẻ.');
