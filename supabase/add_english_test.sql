-- One-time migration to add the naturalization English Test categories
-- (eng_speaking, eng_reading, eng_writing) to an already-deployed database.
-- Run this once in the Supabase SQL editor (Project → SQL Editor → New
-- query). Safe to run even if add_b1b2.sql has already been applied; the
-- constraint step is idempotent, but the inserts are not — run this file
-- exactly once.

-- 1. Widen the category check constraint to allow the English test categories.
alter table questions drop constraint if exists questions_category_check;
alter table questions add constraint questions_category_check
  check (category in (
    'marriage', 'naturalization', 'asylum', 'f1', 'b1b2',
    'eng_speaking', 'eng_reading', 'eng_writing'
  ));

-- 2. Seed Speaking practice: the biographic/personal-history questions an
-- officer asks in English throughout the interview to assess spoken English
-- ability. Like marriage/asylum/F-1/B1B2, these are judgment questions with
-- no single correct answer, so answer_* holds coaching tips.
insert into questions (category, question_en, question_vi, answer_en, answer_vi) values

('eng_speaking', 'What is your full name?', 'Họ tên đầy đủ của anh/chị là gì?',
 'Answer in a full sentence: "My full name is ___." Speak slowly and clearly — this is usually the first question, so a calm, confident answer sets the tone for the interview.',
 'Hãy trả lời bằng một câu đầy đủ: "My full name is ___." Nói chậm và rõ ràng — đây thường là câu hỏi đầu tiên, nên một câu trả lời bình tĩnh, tự tin sẽ tạo ấn tượng tốt cho buổi phỏng vấn.'),

('eng_speaking', 'What is your current home address?', 'Địa chỉ nhà hiện tại của anh/chị là gì?',
 'Practice saying your house number, street name, city, state, and ZIP code out loud in English until it feels natural. Officers ask this to confirm the address on your application.',
 'Hãy luyện nói to số nhà, tên đường, thành phố, tiểu bang và mã ZIP bằng tiếng Anh cho đến khi cảm thấy tự nhiên. Viên chức hỏi câu này để xác nhận địa chỉ đã khai trong hồ sơ.'),

('eng_speaking', 'How long have you lived at your current address?', 'Anh/chị đã sống ở địa chỉ hiện tại bao lâu rồi?',
 'Answer with a simple time phrase: "I have lived here for ___ years/months." Knowing this instantly in English shows familiarity with your own basic information.',
 'Hãy trả lời bằng một cụm từ thời gian đơn giản: "I have lived here for ___ years/months." Biết ngay câu trả lời này bằng tiếng Anh cho thấy anh/chị nắm rõ thông tin cơ bản của mình.'),

('eng_speaking', 'What is your date of birth?', 'Ngày sinh của anh/chị là gì?',
 'Practice saying the full date in English month-day-year order: "I was born on ___." English date order is different from Vietnamese, so this is worth rehearsing out loud.',
 'Hãy luyện nói đầy đủ ngày sinh bằng tiếng Anh theo thứ tự tháng-ngày-năm: "I was born on ___." Thứ tự ngày tháng trong tiếng Anh khác với tiếng Việt, nên câu này rất đáng để luyện nói to.'),

('eng_speaking', 'Are you married? What is your spouse''s name?', 'Anh/chị đã kết hôn chưa? Tên vợ/chồng của anh/chị là gì?',
 'Answer clearly: "Yes, I am married. My spouse''s name is ___." or "No, I am not married." Say your spouse''s full name slowly and clearly if applicable.',
 'Hãy trả lời rõ ràng: "Yes, I am married. My spouse''s name is ___." hoặc "No, I am not married." Nói tên đầy đủ của vợ/chồng chậm và rõ nếu có.'),

('eng_speaking', 'Do you have any children? What are their names and ages?', 'Anh/chị có con không? Tên và tuổi của các con là gì?',
 'Practice listing each child''s full name and age in a simple sentence: "I have ___ children. Their names are ___." Keep it short and clear.',
 'Hãy luyện liệt kê tên đầy đủ và tuổi của từng con bằng một câu đơn giản: "I have ___ children. Their names are ___." Giữ câu trả lời ngắn gọn và rõ ràng.'),

('eng_speaking', 'What is your occupation?', 'Nghề nghiệp của anh/chị là gì?',
 'Answer with a simple job title: "I am a ___" or "I work as a ___." If you are not currently working, you can say "I am currently not employed" or "I am retired."',
 'Hãy trả lời bằng một chức danh công việc đơn giản: "I am a ___" hoặc "I work as a ___." Nếu hiện không đi làm, có thể nói "I am currently not employed" hoặc "I am retired."'),

('eng_speaking', 'How long have you lived in the United States?', 'Anh/chị đã sống ở Mỹ bao lâu rồi?',
 'Answer with a clear time span: "I have lived in the United States for ___ years." This is a very common opening question, so make sure this answer is automatic.',
 'Hãy trả lời bằng một khoảng thời gian rõ ràng: "I have lived in the United States for ___ years." Đây là câu hỏi mở đầu rất thường gặp, nên hãy đảm bảo trả lời được ngay lập tức.'),

('eng_speaking', 'What is your Alien Registration Number, or A-Number?', 'Số Đăng Ký Người Nước Ngoài (A-Number) của anh/chị là gì?',
 'Practice saying your A-Number digit by digit in English ("zero, five, three...") since numbers can be harder to say quickly under nerves. It is printed on your green card and USCIS notices.',
 'Hãy luyện đọc từng số trong A-Number bằng tiếng Anh ("zero, five, three...") vì số có thể khó nói nhanh khi hồi hộp. Số này được in trên thẻ xanh và các thông báo của USCIS.'),

('eng_speaking', 'Have you traveled outside the United States in the last five years?', 'Trong 5 năm qua, anh/chị có đi ra khỏi nước Mỹ không?',
 'Answer "Yes" or "No," and if yes, be ready to briefly name the countries and approximate dates in English. This should match the travel history in your N-400 application.',
 'Hãy trả lời "Yes" hoặc "No," và nếu có, hãy sẵn sàng nêu ngắn gọn tên quốc gia và thời gian đại khái bằng tiếng Anh. Câu trả lời cần khớp với lịch sử du lịch đã khai trong hồ sơ N-400.'),

('eng_speaking', 'Have you ever been arrested, cited, or detained by any law enforcement officer?', 'Anh/chị đã từng bị bắt, bị lập biên bản, hoặc bị giam giữ bởi cơ quan thực thi pháp luật chưa?',
 'Answer honestly with a clear "Yes" or "No." If yes, keep your English answer short and factual — bring related documents, and consider discussing this with an attorney beforehand.',
 'Hãy trả lời trung thực bằng "Yes" hoặc "No" rõ ràng. Nếu có, hãy trả lời ngắn gọn và đúng sự thật bằng tiếng Anh — mang theo giấy tờ liên quan, và nên trao đổi với luật sư trước.'),

('eng_speaking', 'Do you support the Constitution and form of government of the United States?', 'Anh/chị có ủng hộ Hiến Pháp và thể chế chính quyền của Hoa Kỳ không?',
 'Answer clearly and confidently: "Yes, I do." This is one of the standard eligibility questions asked in English near the end of the interview.',
 'Hãy trả lời rõ ràng và tự tin: "Yes, I do." Đây là một trong những câu hỏi điều kiện tiêu chuẩn được hỏi bằng tiếng Anh gần cuối buổi phỏng vấn.'),

('eng_speaking', 'Are you willing to take the Oath of Allegiance to the United States?', 'Anh/chị có sẵn sàng tuyên thệ trung thành với Hoa Kỳ không?',
 'Answer clearly: "Yes, I am willing." Practice saying "Oath of Allegiance" out loud — it is a specific phrase worth rehearsing.',
 'Hãy trả lời rõ ràng: "Yes, I am willing." Hãy luyện nói to cụm từ "Oath of Allegiance" — đây là một cụm từ đặc biệt đáng để luyện tập.'),

('eng_speaking', 'Why do you want to become a United States citizen?', 'Tại sao anh/chị muốn trở thành công dân Hoa Kỳ?',
 'Prepare a short, honest, 2-3 sentence answer in English — for example wanting to vote, get a U.S. passport, or make your status permanent. Practice it out loud so it sounds natural, not memorized word-for-word.',
 'Hãy chuẩn bị một câu trả lời ngắn gọn, trung thực, 2-3 câu bằng tiếng Anh — ví dụ như muốn đi bầu cử, có hộ chiếu Mỹ, hoặc ổn định tình trạng cư trú. Hãy luyện nói to để nghe tự nhiên, không như học thuộc lòng.'),

('eng_speaking', 'What country are you currently a citizen of?', 'Hiện tại anh/chị là công dân của quốc gia nào?',
 'Answer with a simple sentence: "I am currently a citizen of Vietnam." Keep it short and direct.',
 'Hãy trả lời bằng một câu đơn giản: "I am currently a citizen of Vietnam." Giữ câu trả lời ngắn gọn và trực tiếp.'),

('eng_speaking', 'Can you tell me about your daily routine?', 'Anh/chị có thể kể về thói quen hằng ngày của mình không?',
 'This is a good chance to practice free-form spoken English. Talk simply about waking up, going to work, and your evening — this shows natural conversational ability, not just memorized answers.',
 'Đây là cơ hội tốt để luyện tập nói tiếng Anh tự do. Hãy nói đơn giản về việc thức dậy, đi làm, và buổi tối — điều này thể hiện khả năng giao tiếp tự nhiên, không chỉ là câu trả lời học thuộc.');

-- 3. Seed Reading practice sentences. Built only from words in the official
-- USCIS "Reading Vocabulary for the Naturalization Test" list (M-1178,
-- verified live from uscis.gov). USCIS does not publish the exact sentences
-- used in the real test — the officer draws from an internal bank built
-- from this same vocabulary — so these are illustrative practice sentences,
-- not verbatim test content. answer_* holds a reading/pronunciation tip.
insert into questions (category, question_en, question_vi, answer_en, answer_vi) values

('eng_reading', 'Abraham Lincoln was a President.', 'Abraham Lincoln là một Tổng Thống.',
 'Read slowly. Practice the name "Abraham Lincoln" separately first — it is the longest word group in this sentence.',
 'Đọc chậm. Hãy luyện riêng tên "Abraham Lincoln" trước — đây là cụm từ dài nhất trong câu này.'),

('eng_reading', 'George Washington was the first President.', 'George Washington là Tổng Thống đầu tiên.',
 'Pay attention to "first" — make sure the "-st" ending is clear.',
 'Chú ý từ "first" — phát âm rõ phần đuôi "-st".'),

('eng_reading', 'The White House is in America.', 'Nhà Trắng ở nước Mỹ.',
 '"White House" is two words said together smoothly, almost like one word.',
 '"White House" là hai từ được đọc liền mạch với nhau, gần như một từ.'),

('eng_reading', 'The American flag has many colors.', 'Lá cờ Mỹ có nhiều màu sắc.',
 'Practice the "-s" sound at the end of "colors" — it should be clearly audible.',
 'Luyện âm "-s" ở cuối từ "colors" — cần phát âm rõ ràng.'),

('eng_reading', 'A citizen can vote.', 'Một công dân có thể đi bầu cử.',
 'Short sentence — read it at a normal, confident pace, not too fast.',
 'Câu ngắn — đọc với tốc độ bình thường, tự tin, không quá nhanh.'),

('eng_reading', 'The President lives in the White House.', 'Tổng Thống sống ở Nhà Trắng.',
 'Notice "lives" (with a "-z" sound), not "live" — small endings like this matter.',
 'Chú ý từ "lives" (có âm "-z"), không phải "live" — những đuôi từ nhỏ như vậy rất quan trọng.'),

('eng_reading', 'Congress can meet here.', 'Quốc Hội có thể họp ở đây.',
 'Keep "Congress" stressed on the first syllable: CON-gress.',
 'Nhấn trọng âm ở âm tiết đầu của từ "Congress": CON-gress.'),

('eng_reading', 'The Bill of Rights is for the people.', 'Tuyên Ngôn Nhân Quyền là dành cho người dân.',
 '"Bill of Rights" is a set phrase — practice saying all three words smoothly together.',
 '"Bill of Rights" là một cụm từ cố định — hãy luyện đọc liền mạch cả ba từ.'),

('eng_reading', 'Many people want to vote.', 'Nhiều người muốn đi bầu cử.',
 'Read at a steady pace — this sentence has several short words in a row.',
 'Đọc với tốc độ đều — câu này có nhiều từ ngắn liên tiếp nhau.'),

('eng_reading', 'The United States has a President.', 'Hoa Kỳ có một Tổng Thống.',
 '"United States" is often said quickly as one unit — practice it until it flows.',
 '"United States" thường được đọc nhanh như một cụm — hãy luyện đến khi đọc trôi chảy.'),

('eng_reading', 'We have Thanksgiving in America.', 'Chúng tôi có lễ Tạ Ơn ở nước Mỹ.',
 'Break "Thanksgiving" into parts if needed: Thanks-giv-ing.',
 'Nếu cần, hãy tách từ "Thanksgiving" thành các phần: Thanks-giv-ing.'),

('eng_reading', 'Who elects Senators?', 'Ai bầu ra các Thượng Nghị Sĩ?',
 'This is a question — let your voice rise slightly at the end.',
 'Đây là câu hỏi — hãy lên giọng nhẹ ở cuối câu.'),

('eng_reading', 'Where is the White House?', 'Nhà Trắng ở đâu?',
 'Question intonation again — rising tone at the end on "House."',
 'Ngữ điệu câu hỏi — lên giọng ở cuối câu tại từ "House."'),

('eng_reading', 'Why do people vote?', 'Tại sao người dân đi bầu cử?',
 'Keep "do" light and quick — it is not the stressed word in this question.',
 'Đọc từ "do" nhẹ và nhanh — đây không phải từ được nhấn trọng âm trong câu hỏi này.'),

('eng_reading', 'What is the capital?', 'Thủ đô là gì?',
 'Short, direct question — practice a natural rising tone on "capital."',
 'Câu hỏi ngắn, trực tiếp — luyện lên giọng tự nhiên ở từ "capital."'),

('eng_reading', 'How many Senators are in Congress?', 'Có bao nhiêu Thượng Nghị Sĩ trong Quốc Hội?',
 'Longer sentence — take a small breath after "Senators" if you need to.',
 'Câu dài hơn — có thể ngắt hơi nhẹ sau từ "Senators" nếu cần.'),

('eng_reading', 'When is Labor Day?', 'Ngày Lễ Lao Động là khi nào?',
 'Practice "Labor Day" as one smooth phrase.',
 'Luyện đọc "Labor Day" như một cụm liền mạch.'),

('eng_reading', 'When is Flag Day?', 'Ngày Lễ Cờ là khi nào?',
 'Short and simple — a good sentence to build reading confidence.',
 'Ngắn và đơn giản — một câu tốt để xây dựng sự tự tin khi đọc.');

-- 4. Seed Writing practice sentences. Built only from words in the official
-- USCIS "Writing Vocabulary for the Naturalization Test" list (M-1178,
-- verified live from uscis.gov — note this list is separate from the
-- Reading list and uses some different words, e.g. surnames only for
-- people and no articles like "a"). Same caveat as Reading: USCIS does not
-- publish exact test sentences, only the vocabulary. answer_* holds a
-- spelling/listening tip. The app reads each sentence aloud (browser
-- text-to-speech) and hides the text until the client reveals it, mirroring
-- the real dictation-style writing test.
insert into questions (category, question_en, question_vi, answer_en, answer_vi) values

('eng_writing', 'Washington was the first President.', 'Washington là Tổng Thống đầu tiên.',
 'Check your capitalization: "Washington" and "President" both start with a capital letter.',
 'Kiểm tra chữ viết hoa: "Washington" và "President" đều viết hoa chữ cái đầu.'),

('eng_writing', 'Citizens have the right to vote.', 'Công dân có quyền đi bầu cử.',
 'Double-check the spelling of "citizens" — plural, ending in "-s".',
 'Kiểm tra lại chính tả từ "citizens" — số nhiều, kết thúc bằng "-s".'),

('eng_writing', 'The flag is red, white, and blue.', 'Lá cờ có màu đỏ, trắng và xanh dương.',
 'Remember the commas between each color, and "and" before the last one.',
 'Nhớ dấu phẩy giữa mỗi màu, và từ "and" trước màu cuối cùng.'),

('eng_writing', 'Congress meets in Washington, D.C.', 'Quốc Hội họp tại Washington, D.C.',
 'Write "D.C." with both periods and a capital D and C.',
 'Viết "D.C." với đầy đủ hai dấu chấm và chữ D, C viết hoa.'),

('eng_writing', 'We pay taxes.', 'Chúng tôi đóng thuế.',
 'Short sentence — a good one to double-check spelling carefully since there are no other words to lean on.',
 'Câu ngắn — nên kiểm tra chính tả thật kỹ vì không có từ nào khác để dựa vào.'),

('eng_writing', 'People want to vote.', 'Người dân muốn đi bầu cử.',
 'Check the spelling of "people" — a commonly misspelled word.',
 'Kiểm tra chính tả từ "people" — một từ thường hay viết sai.'),

('eng_writing', 'The President can vote.', 'Tổng Thống có thể đi bầu cử.',
 'Remember the capital letter on "President" when referring to the U.S. President.',
 'Nhớ viết hoa chữ cái đầu của "President" khi nói về Tổng Thống Hoa Kỳ.'),

('eng_writing', 'Lincoln was the President.', 'Lincoln là Tổng Thống.',
 'Only the surname "Lincoln" is used in writing practice — no first name needed.',
 'Chỉ cần viết họ "Lincoln" trong bài luyện viết — không cần tên đầy đủ.'),

('eng_writing', 'Adams was the second President.', 'Adams là Tổng Thống thứ hai.',
 'Check the spelling of "second" — it has a silent-feeling "c".',
 'Kiểm tra chính tả từ "second" — có chữ "c" đọc nhẹ.'),

('eng_writing', 'The capital is Washington, D.C.', 'Thủ đô là Washington, D.C.',
 'Same "Washington, D.C." spelling as other sentences — write it consistently.',
 'Chính tả "Washington, D.C." giống các câu khác — viết nhất quán.'),

('eng_writing', 'Most people want to be free.', 'Hầu hết mọi người đều muốn được tự do.',
 'Check the spelling of "free" — one word, double "e".',
 'Kiểm tra chính tả từ "free" — một từ, có hai chữ "e".'),

('eng_writing', 'New York City is in the United States.', 'Thành Phố New York ở Hoa Kỳ.',
 '"New York City" is three separate capitalized words.',
 '"New York City" là ba từ riêng biệt, mỗi từ đều viết hoa.'),

('eng_writing', 'Alaska is north of Canada.', 'Alaska ở phía bắc Canada.',
 'This sentence is a common mix-up — actually Alaska is northwest of Canada; still a useful spelling practice sentence for "Alaska" and "Canada".',
 'Câu này thường bị nhầm lẫn — thực ra Alaska nằm ở phía tây bắc Canada; vẫn là câu luyện chính tả hữu ích cho từ "Alaska" và "Canada".'),

('eng_writing', 'Mexico is south of the United States.', 'Mexico ở phía nam Hoa Kỳ.',
 'Double-check "Mexico" — capital M, and the "x" sound.',
 'Kiểm tra lại từ "Mexico" — chữ M viết hoa, và âm "x".'),

('eng_writing', 'Citizens have freedom of speech.', 'Công dân có quyền tự do ngôn luận.',
 '"Freedom of speech" is a three-word set phrase — practice writing all three words together.',
 '"Freedom of speech" là cụm ba từ cố định — hãy luyện viết cả ba từ cùng nhau.'),

('eng_writing', 'Lincoln was President during the Civil War.', 'Lincoln là Tổng Thống trong thời kỳ Nội Chiến.',
 '"Civil War" is capitalized as a specific historical event.',
 '"Civil War" được viết hoa vì là tên riêng của một sự kiện lịch sử.'),

('eng_writing', 'American Indians lived in the United States.', 'Người Mỹ Bản Địa đã sống ở Hoa Kỳ.',
 '"American Indians" — both words capitalized, this is the official USCIS vocabulary term.',
 '"American Indians" — cả hai từ đều viết hoa, đây là thuật ngữ chính thức trong danh sách từ vựng của USCIS.'),

('eng_writing', 'Independence Day is in July.', 'Ngày Độc Lập là vào tháng Bảy.',
 'Months are always capitalized in English: "July".',
 'Tên tháng luôn viết hoa trong tiếng Anh: "July".'),

('eng_writing', 'Memorial Day is in May.', 'Lễ Tưởng Niệm là vào tháng Năm.',
 'Short sentence — double-check "Memorial" is spelled with one "m" in the middle.',
 'Câu ngắn — kiểm tra lại từ "Memorial" chỉ có một chữ "m" ở giữa.'),

('eng_writing', 'Presidents'' Day is in February.', 'Ngày Tổng Thống là vào tháng Hai.',
 'Note the apostrophe after the "s" in "Presidents'' Day" (plural possessive).',
 'Chú ý dấu nháy đơn sau chữ "s" trong "Presidents'' Day" (sở hữu cách số nhiều).');
