-- One-time migration: expand the F-1 student visa category and add red-flag
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

-- 1. New F-1 PRACTICE QUESTIONS (brings the bank from ~19 to ~55). These are
--    consular-interview questions; answer_* holds coaching tips. The recurring
--    themes a visa officer weighs: genuine student intent, ability to pay, and
--    strong ties that will bring you back to Vietnam.
insert into questions (category, content_type, question_en, question_vi, answer_en, answer_vi) values

('f1', 'question', 'What is the name and location of the school you will attend?', 'Tên và địa điểm trường anh/chị sẽ theo học là gì?',
 'Know your school''s name, city, and state confidently. Not knowing basic facts about your own school is an immediate warning sign.',
 'Hãy biết rõ tên trường, thành phố, và tiểu bang một cách tự tin. Không biết những thông tin cơ bản về trường của chính mình là dấu hiệu cảnh báo ngay lập tức.'),

('f1', 'question', 'How did you find this school, and did you apply to others?', 'Anh/chị biết đến trường này bằng cách nào, và có nộp đơn vào trường nào khác không?',
 'Explain your research process and any other schools you applied to. A genuine student can describe why this school stood out.',
 'Hãy giải thích quá trình tìm hiểu của anh/chị và những trường khác đã nộp đơn. Một sinh viên thật sự có thể nói rõ vì sao trường này nổi bật.'),

('f1', 'question', 'What is your intended program and start date?', 'Chương trình học và ngày nhập học dự kiến của anh/chị là gì?',
 'State your program and the term you will begin, matching your I-20. These basic facts should come easily.',
 'Hãy nêu chương trình học và học kỳ anh/chị sẽ bắt đầu, khớp với mẫu I-20. Những thông tin cơ bản này phải trả lời được dễ dàng.'),

('f1', 'question', 'What academic qualifications make you a good fit for this program?', 'Những thành tích học tập nào cho thấy anh/chị phù hợp với chương trình này?',
 'Mention your GPA, prior degree, or relevant coursework. Show that you are academically prepared for the program.',
 'Hãy nêu điểm trung bình, bằng cấp trước đó, hoặc các môn học liên quan. Hãy cho thấy anh/chị đã được chuẩn bị về mặt học thuật cho chương trình.'),

('f1', 'question', 'Can you describe the courses you will take in your first year?', 'Anh/chị có thể mô tả các môn sẽ học trong năm đầu tiên không?',
 'Knowing some of your actual courses shows real intent to study. Review your program''s curriculum beforehand.',
 'Biết một số môn học thực tế cho thấy ý định học tập thật sự. Hãy xem trước chương trình giảng dạy của ngành.'),

('f1', 'question', 'Why is this program better for you than a similar one in Vietnam?', 'Vì sao chương trình này tốt hơn cho anh/chị so với một chương trình tương tự ở Việt Nam?',
 'Give concrete reasons — specialization, faculty, facilities, or reputation — rather than a vague preference for studying abroad.',
 'Hãy đưa ra lý do cụ thể — chuyên ngành, giảng viên, cơ sở vật chất, hay uy tín — thay vì chỉ nói chung chung là thích đi du học.'),

('f1', 'question', 'What is your career goal, and how will this degree help it in Vietnam?', 'Mục tiêu nghề nghiệp của anh/chị là gì, và tấm bằng này sẽ giúp gì cho mục tiêu đó ở Việt Nam?',
 'Connect your degree to a specific career back home. A clear plan to use the degree in Vietnam supports your intent to return.',
 'Hãy liên hệ tấm bằng với một nghề nghiệp cụ thể ở quê nhà. Một kế hoạch rõ ràng để dùng tấm bằng ở Việt Nam củng cố ý định quay về của anh/chị.'),

('f1', 'question', 'What kind of job and salary do you expect after you return to Vietnam?', 'Anh/chị mong đợi công việc và mức lương thế nào sau khi trở về Việt Nam?',
 'Show you have researched real opportunities in your field at home. Realistic expectations signal genuine plans to return.',
 'Hãy cho thấy anh/chị đã tìm hiểu các cơ hội thực tế trong ngành ở quê nhà. Kỳ vọng hợp lý cho thấy kế hoạch quay về là thật.'),

('f1', 'question', 'Who is your financial sponsor, and what is their occupation and annual income?', 'Người tài trợ tài chính cho anh/chị là ai, và họ làm nghề gì với thu nhập hằng năm bao nhiêu?',
 'Know your sponsor''s job and income clearly, and be ready to show it matches your funding documents.',
 'Hãy biết rõ nghề nghiệp và thu nhập của người tài trợ, và sẵn sàng chứng minh nó khớp với giấy tờ tài chính.'),

('f1', 'question', 'How much money does your sponsor have available to fund your studies?', 'Người tài trợ có sẵn bao nhiêu tiền để chi trả cho việc học của anh/chị?',
 'Be able to state the funds available and that they cover tuition and living costs for your program. Vague answers about money worry officers.',
 'Hãy nêu được số tiền có sẵn và rằng nó đủ trang trải học phí và sinh hoạt cho chương trình. Câu trả lời mơ hồ về tiền khiến viên chức lo ngại.'),

('f1', 'question', 'Can you explain any large recent deposits in your bank statements?', 'Anh/chị có thể giải thích các khoản tiền lớn mới gửi vào trong sao kê ngân hàng không?',
 'Officers are wary of funds that appear suddenly for the visa. Be ready to document the legitimate source of any large deposit.',
 'Viên chức nghi ngại những khoản tiền xuất hiện đột ngột để xin visa. Hãy sẵn sàng chứng minh nguồn gốc hợp pháp của mọi khoản tiền lớn.'),

('f1', 'question', 'What is the total cost of your program, including tuition and living expenses?', 'Tổng chi phí chương trình của anh/chị, bao gồm học phí và sinh hoạt, là bao nhiêu?',
 'Know the full yearly cost from your I-20. Understanding what your education actually costs shows you are a serious, prepared student.',
 'Hãy biết tổng chi phí hằng năm từ mẫu I-20. Hiểu rõ chi phí học tập thực tế cho thấy anh/chị là một sinh viên nghiêm túc, có chuẩn bị.'),

('f1', 'question', 'Do you have a scholarship or assistantship? What does it cover?', 'Anh/chị có học bổng hoặc trợ giảng không? Nó chi trả những gì?',
 'If you have funding from the school, know exactly what it covers and bring the award letter. If not, be clear on how you cover the full cost.',
 'Nếu có tài trợ từ trường, hãy biết chính xác nó chi trả những gì và mang theo thư cấp học bổng. Nếu không, hãy nói rõ cách anh/chị trang trải toàn bộ chi phí.'),

('f1', 'question', 'Where will you live while you study in the United States?', 'Anh/chị sẽ sống ở đâu trong thời gian học tại Hoa Kỳ?',
 'Have a realistic plan — on-campus housing, a dorm, or renting near school. A concrete answer shows genuine preparation.',
 'Hãy có kế hoạch thực tế — ký túc xá, nhà ở trong trường, hay thuê gần trường. Câu trả lời cụ thể cho thấy sự chuẩn bị thật sự.'),

('f1', 'question', 'What is the SEVIS ID and school listed on your Form I-20?', 'Mã SEVIS và trường ghi trên mẫu I-20 của anh/chị là gì?',
 'You do not need to memorize the number, but you should have your I-20 in hand and know the school it lists matches your plans.',
 'Anh/chị không cần thuộc lòng con số, nhưng nên cầm sẵn mẫu I-20 và biết trường ghi trên đó khớp với kế hoạch của mình.'),

('f1', 'question', 'Did you pay the SEVIS (I-901) fee?', 'Anh/chị đã đóng phí SEVIS (I-901) chưa?',
 'You must pay the SEVIS fee before the interview. Bring the receipt as proof.',
 'Anh/chị phải đóng phí SEVIS trước buổi phỏng vấn. Hãy mang biên lai làm bằng chứng.'),

('f1', 'question', 'What is your major, and what specific topics in it interest you?', 'Chuyên ngành của anh/chị là gì, và những chủ đề cụ thể nào trong đó khiến anh/chị hứng thú?',
 'Speak with genuine enthusiasm about your field. Real interest is hard to fake and reassures the officer you are a true student.',
 'Hãy nói bằng sự hứng thú thật sự về ngành của anh/chị. Đam mê thật khó giả tạo và giúp viên chức yên tâm rằng anh/chị là sinh viên thật.'),

('f1', 'question', 'What is your current level of education and where did you study?', 'Trình độ học vấn hiện tại của anh/chị là gì và anh/chị đã học ở đâu?',
 'Summarize your education so far. It should form a logical path leading to the program you are about to begin.',
 'Hãy tóm tắt quá trình học của anh/chị đến nay. Nó phải tạo thành một lộ trình hợp lý dẫn đến chương trình anh/chị sắp bắt đầu.'),

('f1', 'question', 'What was your score on TOEFL, IELTS, or Duolingo?', 'Điểm TOEFL, IELTS, hoặc Duolingo của anh/chị là bao nhiêu?',
 'Know your score and that it meets your school''s requirement. Bring the score report.',
 'Hãy biết điểm của mình và rằng nó đạt yêu cầu của trường. Hãy mang bảng điểm.'),

('f1', 'question', 'The program is taught in English — how will you handle studying in English?', 'Chương trình dạy bằng tiếng Anh — anh/chị sẽ theo học bằng tiếng Anh như thế nào?',
 'Answer in clear English, and mention your preparation (test scores, prior English study). Demonstrating comfort in English here helps a lot.',
 'Hãy trả lời bằng tiếng Anh rõ ràng, và nêu sự chuẩn bị của anh/chị (điểm thi, việc học tiếng Anh trước đó). Thể hiện sự thành thạo tiếng Anh ở đây rất có lợi.'),

('f1', 'question', 'Do you have relatives in the United States, and what is their immigration status?', 'Anh/chị có người thân ở Hoa Kỳ không, và tình trạng di trú của họ là gì?',
 'Answer truthfully. Having relatives there is not disqualifying, but be ready to explain that it does not change your plan to return to Vietnam.',
 'Hãy trả lời trung thực. Có người thân ở đó không khiến bị từ chối, nhưng hãy sẵn sàng giải thích rằng điều đó không thay đổi kế hoạch quay về Việt Nam của anh/chị.'),

('f1', 'question', 'Will any family members travel with you as dependents?', 'Có người thân nào đi cùng anh/chị với tư cách người phụ thuộc không?',
 'If a spouse or child will come on an F-2 visa, say so and be ready with their documents. If not, a simple no is fine.',
 'Nếu vợ/chồng hoặc con sẽ đi cùng bằng visa F-2, hãy nói rõ và chuẩn bị sẵn giấy tờ của họ. Nếu không, chỉ cần trả lời không.'),

('f1', 'question', 'What do your parents do for a living?', 'Cha mẹ anh/chị làm nghề gì?',
 'Describe their occupations. This helps the officer understand your family''s ties in Vietnam and your funding.',
 'Hãy mô tả nghề nghiệp của họ. Điều này giúp viên chức hiểu mối ràng buộc gia đình của anh/chị ở Việt Nam và nguồn tài chính.'),

('f1', 'question', 'Does your family own property or a business in Vietnam?', 'Gia đình anh/chị có sở hữu nhà đất hay doanh nghiệp ở Việt Nam không?',
 'Property and businesses are strong ties to Vietnam. Mention them honestly, as they support your intent to return.',
 'Nhà đất và doanh nghiệp là những ràng buộc mạnh với Việt Nam. Hãy nêu ra trung thực, vì chúng củng cố ý định quay về của anh/chị.'),

('f1', 'question', 'Have you traveled abroad before? To which countries?', 'Anh/chị đã từng đi nước ngoài chưa? Những nước nào?',
 'List your prior travel. A record of traveling and returning on time supports your credibility.',
 'Hãy liệt kê các chuyến đi trước đây. Lịch sử đi và về đúng hạn củng cố độ tin cậy của anh/chị.'),

('f1', 'question', 'Have you ever overstayed a visa or stayed abroad without status?', 'Anh/chị đã từng ở quá hạn visa hoặc ở nước ngoài không có tình trạng hợp pháp chưa?',
 'Answer honestly. If there is such history, be ready to explain it; hiding it is far more damaging than a truthful account.',
 'Hãy trả lời trung thực. Nếu có lịch sử như vậy, hãy sẵn sàng giải thích; giấu giếm gây hại hơn nhiều so với một lời khai thành thật.'),

('f1', 'question', 'What will you do during school breaks and holidays?', 'Anh/chị sẽ làm gì trong các kỳ nghỉ và ngày lễ?',
 'A reasonable answer — studying, campus activities, or visiting family in Vietnam — shows you understand student life and intend to return.',
 'Một câu trả lời hợp lý — học tập, hoạt động ở trường, hay về thăm gia đình ở Việt Nam — cho thấy anh/chị hiểu đời sống sinh viên và có ý định quay về.'),

('f1', 'question', 'Do you understand the rules about working while on an F-1 visa?', 'Anh/chị có hiểu các quy định về việc làm khi mang visa F-1 không?',
 'Show you know F-1 work is limited (generally on-campus, or CPT/OPT tied to your studies). This signals you intend to follow the rules.',
 'Hãy cho thấy anh/chị biết việc làm khi có F-1 bị giới hạn (thường là trong trường, hoặc CPT/OPT gắn với việc học). Điều này cho thấy anh/chị có ý định tuân thủ quy định.'),

('f1', 'question', 'After you finish your studies (and any OPT), what is your plan?', 'Sau khi hoàn tất việc học (và OPT nếu có), kế hoạch của anh/chị là gì?',
 'Emphasize returning to Vietnam to build your career. A clear post-graduation plan back home is one of the most important points.',
 'Hãy nhấn mạnh việc quay về Việt Nam để xây dựng sự nghiệp. Một kế hoạch rõ ràng sau tốt nghiệp ở quê nhà là một trong những điểm quan trọng nhất.'),

('f1', 'question', 'Why should the officer believe you will return to Vietnam after your studies?', 'Vì sao viên chức nên tin rằng anh/chị sẽ quay về Việt Nam sau khi học xong?',
 'Point to concrete ties — family, property, career prospects, and your specific plans at home. Confident, specific ties are the heart of an F-1 approval.',
 'Hãy nêu các ràng buộc cụ thể — gia đình, nhà đất, triển vọng nghề nghiệp, và kế hoạch cụ thể ở quê nhà. Các ràng buộc rõ ràng, cụ thể là cốt lõi để được cấp F-1.'),

('f1', 'question', 'Who advised or helped you choose this school and major?', 'Ai đã tư vấn hoặc giúp anh/chị chọn trường và ngành này?',
 'It is fine to have had guidance, but you should own the decision and explain it in your own words, showing it is genuinely your choice.',
 'Được người khác tư vấn là bình thường, nhưng anh/chị nên làm chủ quyết định và giải thích bằng lời của mình, cho thấy đó thật sự là lựa chọn của anh/chị.'),

('f1', 'question', 'How does your chosen field offer opportunities specifically in Vietnam?', 'Ngành anh/chị chọn mang lại cơ hội cụ thể như thế nào ở Việt Nam?',
 'Show you have thought about the job market at home for your field. This links your studies to a future in Vietnam.',
 'Hãy cho thấy anh/chị đã suy nghĩ về thị trường việc làm ở quê nhà cho ngành của mình. Điều này gắn việc học với tương lai ở Việt Nam.'),

('f1', 'question', 'What will you do if your visa is denied today?', 'Anh/chị sẽ làm gì nếu hôm nay visa bị từ chối?',
 'Answer calmly — you would continue your plans, perhaps reapply or study locally. A composed answer shows you are not desperate to leave Vietnam permanently.',
 'Hãy trả lời bình tĩnh — anh/chị sẽ tiếp tục kế hoạch, có thể nộp lại hoặc học trong nước. Một câu trả lời điềm tĩnh cho thấy anh/chị không cố rời Việt Nam vĩnh viễn bằng mọi giá.'),

('f1', 'question', 'How will your family manage financially and personally while you are away?', 'Gia đình anh/chị sẽ xoay xở về tài chính và cuộc sống ra sao khi anh/chị đi vắng?',
 'Show that your family is stable without you and expects you back. This reinforces that your absence is temporary.',
 'Hãy cho thấy gia đình anh/chị vẫn ổn định khi không có anh/chị và mong anh/chị trở về. Điều này khẳng định sự vắng mặt của anh/chị chỉ là tạm thời.'),

('f1', 'question', 'Do you have your I-20, SEVIS receipt, DS-160 confirmation, and admission letter ready today?', 'Hôm nay anh/chị đã chuẩn bị sẵn I-20, biên lai SEVIS, xác nhận DS-160, và thư nhập học chưa?',
 'Have your core documents organized and easy to hand over. Being prepared makes a strong first impression.',
 'Hãy sắp xếp sẵn các giấy tờ cốt lõi và dễ đưa ra. Sự chuẩn bị chu đáo tạo ấn tượng đầu tiên tốt.');

-- 2. F-1 RED FLAGS.
insert into questions (category, content_type, question_en, question_vi, answer_en, answer_vi) values

('f1', 'red_flag', 'Answers that hint you plan to stay or work in the U.S. long-term', 'Câu trả lời ám chỉ anh/chị định ở lại hoặc làm việc lâu dài ở Mỹ',
 'F-1 is a temporary student visa. Talk of settling, finding permanent work, or joining relatives suggests immigrant intent. Keep the focus on studying and returning to Vietnam.',
 'F-1 là visa sinh viên tạm thời. Nói về việc định cư, tìm việc lâu dài, hay về đoàn tụ với người thân cho thấy ý định định cư. Hãy tập trung vào việc học và quay về Việt Nam.'),

('f1', 'red_flag', 'Weak or vague ties to Vietnam', 'Ràng buộc với Việt Nam yếu hoặc mơ hồ',
 'Officers approve students they believe will return. If your ties — family, property, career plans — sound weak, strengthen how you describe them with concrete specifics.',
 'Viên chức cấp visa cho những sinh viên mà họ tin sẽ quay về. Nếu các ràng buộc của anh/chị — gia đình, nhà đất, kế hoạch nghề nghiệp — nghe có vẻ yếu, hãy mô tả chúng cụ thể và rõ ràng hơn.'),

('f1', 'red_flag', 'Not knowing basic details about your school or program', 'Không biết những thông tin cơ bản về trường hoặc chương trình',
 'A real student knows their school, major, and courses. Vagueness here is one of the fastest ways to a denial — study your own program before the interview.',
 'Một sinh viên thật sự biết trường, ngành, và các môn học của mình. Sự mơ hồ ở đây là một trong những cách nhanh nhất dẫn đến bị từ chối — hãy tìm hiểu kỹ chương trình của mình trước buổi phỏng vấn.'),

('f1', 'red_flag', 'Being unable to explain who pays or the source of funds', 'Không giải thích được ai chi trả hoặc nguồn tiền',
 'You must clearly show funding covers your full costs and comes from a legitimate source. Confusion about money is a major reason for denial.',
 'Anh/chị phải chứng minh rõ nguồn tiền đủ trang trải toàn bộ chi phí và đến từ nguồn hợp pháp. Sự lúng túng về tiền bạc là lý do lớn dẫn đến bị từ chối.'),

('f1', 'red_flag', 'Large, unexplained recent deposits in your bank account', 'Các khoản tiền lớn mới gửi vào tài khoản mà không giải thích được',
 'Money that appears suddenly right before the interview looks staged. Be ready to document where any large deposit genuinely came from.',
 'Tiền xuất hiện đột ngột ngay trước buổi phỏng vấn trông giống dàn dựng. Hãy sẵn sàng chứng minh nguồn gốc thật của mọi khoản tiền lớn.'),

('f1', 'red_flag', 'A school or major that does not fit your background or goals', 'Trường hoặc ngành không phù hợp với nền tảng hoặc mục tiêu của anh/chị',
 'A program that doesn''t match your education or career plan raises doubt about your true purpose. Be ready to explain why this path makes sense for you.',
 'Một chương trình không khớp với học vấn hoặc kế hoạch nghề nghiệp gây nghi ngờ về mục đích thật của anh/chị. Hãy sẵn sàng giải thích vì sao lộ trình này hợp lý với anh/chị.'),

('f1', 'red_flag', 'Answers that sound memorized rather than genuine', 'Câu trả lời nghe như học thuộc thay vì tự nhiên',
 'Scripted responses make officers suspicious. Understand your own plans well enough to speak naturally and answer follow-up questions.',
 'Câu trả lời như đọc bài khiến viên chức nghi ngờ. Hãy hiểu rõ kế hoạch của mình đủ để nói tự nhiên và trả lời các câu hỏi phụ.'),

('f1', 'red_flag', 'Weak English when the program is taught in English', 'Tiếng Anh yếu trong khi chương trình dạy bằng tiếng Anh',
 'If you struggle to answer simple questions in English, the officer doubts you can succeed academically. Practice speaking and lean on your test scores.',
 'Nếu anh/chị chật vật trả lời những câu đơn giản bằng tiếng Anh, viên chức sẽ nghi ngờ khả năng học tập của anh/chị. Hãy luyện nói và dựa vào điểm thi của mình.'),

('f1', 'red_flag', 'A career goal with no logical reason to return to Vietnam', 'Mục tiêu nghề nghiệp không có lý do hợp lý để quay về Việt Nam',
 'If your stated goals only make sense in the U.S., it signals you may not return. Frame your ambitions around opportunities and a future back home.',
 'Nếu mục tiêu của anh/chị chỉ hợp lý ở Mỹ, điều đó cho thấy anh/chị có thể không quay về. Hãy đặt tham vọng của mình quanh các cơ hội và tương lai ở quê nhà.'),

('f1', 'red_flag', 'History of visa denials or overstays left unaddressed', 'Lịch sử bị từ chối visa hoặc ở quá hạn mà không đề cập',
 'Prior denials or overstays don''t automatically disqualify you, but ignoring them does. Acknowledge your history honestly and explain what has changed.',
 'Việc từng bị từ chối visa hoặc ở quá hạn không tự động khiến anh/chị bị loại, nhưng phớt lờ chúng thì có. Hãy thừa nhận lịch sử một cách trung thực và giải thích điều gì đã thay đổi.'),

('f1', 'red_flag', 'Contradicting your DS-160 or supporting documents', 'Mâu thuẫn với DS-160 hoặc giấy tờ kèm theo',
 'Officers have your DS-160 in front of them. Make sure your spoken answers match what you wrote about your school, funding, and family.',
 'Viên chức có mẫu DS-160 trước mặt. Hãy đảm bảo câu trả lời miệng khớp với những gì anh/chị đã ghi về trường, tài chính, và gia đình.'),

('f1', 'red_flag', 'Relying on relatives in the U.S. rather than a study plan', 'Dựa vào người thân ở Mỹ thay vì một kế hoạch học tập',
 'If your answers center on relatives in the U.S. rather than your education, it looks like the visa is really about joining them. Keep the emphasis on your studies.',
 'Nếu câu trả lời của anh/chị xoay quanh người thân ở Mỹ thay vì việc học, nó trông giống như visa thật ra là để đoàn tụ với họ. Hãy giữ trọng tâm vào việc học của anh/chị.');

-- 3. F-1 DOCUMENT CHECKLIST.
insert into questions (category, content_type, question_en, question_vi, answer_en, answer_vi) values

('f1', 'checklist', 'Valid passport', 'Hộ chiếu còn hiệu lực',
 'Bring your passport, valid for at least six months beyond your intended stay, plus any old passports with prior visas.',
 'Hãy mang hộ chiếu còn hiệu lực ít nhất sáu tháng sau thời gian dự định ở lại, cùng các hộ chiếu cũ có visa trước đây.'),

('f1', 'checklist', 'DS-160 confirmation page', 'Trang xác nhận DS-160',
 'Bring the printed confirmation with the barcode. You cannot be interviewed without it.',
 'Hãy mang trang xác nhận đã in có mã vạch. Anh/chị không thể được phỏng vấn nếu thiếu nó.'),

('f1', 'checklist', 'Visa interview appointment confirmation', 'Xác nhận lịch hẹn phỏng vấn visa',
 'Bring your appointment letter with the date and time of your interview.',
 'Hãy mang thư hẹn có ngày và giờ phỏng vấn của anh/chị.'),

('f1', 'checklist', 'Form I-20, signed', 'Mẫu I-20, đã ký',
 'Your school issues the I-20; sign it and bring the original. It is the core document of your student status.',
 'Trường của anh/chị cấp mẫu I-20; hãy ký và mang bản gốc. Đây là giấy tờ cốt lõi cho tình trạng sinh viên của anh/chị.'),

('f1', 'checklist', 'SEVIS (I-901) fee receipt', 'Biên lai phí SEVIS (I-901)',
 'You must pay the SEVIS fee before your interview — bring the receipt as proof.',
 'Anh/chị phải đóng phí SEVIS trước buổi phỏng vấn — hãy mang biên lai làm bằng chứng.'),

('f1', 'checklist', 'School admission letter', 'Thư nhập học của trường',
 'Bring your official acceptance letter confirming you have been admitted to the program.',
 'Hãy mang thư chấp nhận chính thức xác nhận anh/chị đã được nhận vào chương trình.'),

('f1', 'checklist', 'Academic records — transcripts and diplomas', 'Hồ sơ học tập — bảng điểm và bằng cấp',
 'Bring transcripts, diplomas, and certificates from your previous schooling to show your academic background.',
 'Hãy mang bảng điểm, bằng cấp, và chứng chỉ từ quá trình học trước đây để cho thấy nền tảng học vấn của anh/chị.'),

('f1', 'checklist', 'Standardized test scores', 'Bảng điểm các kỳ thi chuẩn hóa',
 'Bring your TOEFL, IELTS, or Duolingo results, plus SAT/GRE/GMAT if your program required them.',
 'Hãy mang kết quả TOEFL, IELTS, hoặc Duolingo, cùng SAT/GRE/GMAT nếu chương trình yêu cầu.'),

('f1', 'checklist', 'Financial evidence', 'Bằng chứng tài chính',
 'Bank statements, a sponsor letter, and proof of income showing you can cover tuition and living costs for the full program.',
 'Sao kê ngân hàng, thư bảo trợ, và bằng chứng thu nhập cho thấy anh/chị có thể trang trải học phí và sinh hoạt cho toàn bộ chương trình.'),

('f1', 'checklist', 'Scholarship or assistantship letter, if any', 'Thư học bổng hoặc trợ giảng, nếu có',
 'If the school is funding part of your costs, bring the official award letter stating what it covers.',
 'Nếu trường tài trợ một phần chi phí, hãy mang thư cấp chính thức nêu rõ nó chi trả những gì.'),

('f1', 'checklist', 'Proof of ties to Vietnam', 'Bằng chứng ràng buộc với Việt Nam',
 'Property papers, family business documents, or evidence of career prospects support your intent to return home.',
 'Giấy tờ nhà đất, giấy tờ doanh nghiệp gia đình, hoặc bằng chứng về triển vọng nghề nghiệp củng cố ý định quay về của anh/chị.'),

('f1', 'checklist', 'Sponsor''s employment and income documents', 'Giấy tờ việc làm và thu nhập của người bảo trợ',
 'Bring your sponsor''s job letter, pay slips, or business records to back up the funding for your studies.',
 'Hãy mang thư xác nhận việc làm, phiếu lương, hoặc hồ sơ kinh doanh của người bảo trợ để chứng minh nguồn tài chính cho việc học.'),

('f1', 'checklist', 'Passport photo(s) meeting U.S. visa requirements', 'Ảnh thẻ đạt yêu cầu visa Hoa Kỳ',
 'Bring a recent photo in the required U.S. visa format in case one is needed at the interview.',
 'Hãy mang một ảnh chụp gần đây theo đúng định dạng visa Hoa Kỳ phòng khi cần tại buổi phỏng vấn.'),

('f1', 'checklist', 'Originals plus copies, organized', 'Bản gốc kèm bản sao, sắp xếp gọn gàng',
 'Bring originals for the officer to see and copies to leave. Organized documents make the interview quick and smooth.',
 'Hãy mang bản gốc để viên chức xem và bản sao để nộp lại. Giấy tờ được sắp xếp giúp buổi phỏng vấn nhanh và suôn sẻ.');
