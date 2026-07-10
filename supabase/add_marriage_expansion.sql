-- One-time migration: expand the marriage-based green card category and
-- introduce two new content types — "red_flag" (common mistakes / warning
-- signs officers look for) and "checklist" (documents to bring). Run this
-- once in the Supabase SQL editor (Project → SQL Editor → New query).
--
-- ⚠  Run this file exactly once — the INSERTs would duplicate rows if run
--    twice.
--
-- This is the PILOT for the "double down on the open field" expansion. Once
-- reviewed, the same three content types (question / red_flag / checklist)
-- will be added for asylum, F-1, and B1/B2 the same way.

-- 1. Add a content_type discriminator to the questions table. Existing rows
--    (all practice questions) become 'question' via the default. Red flags and
--    checklist items reuse the same table and category, tagged by this column;
--    the app filters on it and shows a per-category sub-toggle
--    (Practice Questions / Red Flags / Documents).
alter table questions
  add column if not exists content_type text not null default 'question';

alter table questions drop constraint if exists questions_content_type_check;
alter table questions add constraint questions_content_type_check
  check (content_type in ('question', 'red_flag', 'checklist'));

-- 2. New marriage PRACTICE QUESTIONS (brings the bank from ~19 to ~56).
--    Like the existing ones, these are judgment/personal-history questions
--    with no single correct answer, so answer_* holds coaching tips. The
--    consistent theme: answer truthfully and match what your spouse would say.
insert into questions (category, content_type, question_en, question_vi, answer_en, answer_vi) values

('marriage', 'question', 'Who proposed, and how did the proposal happen?', 'Ai là người cầu hôn, và lời cầu hôn diễn ra như thế nào?',
 'Tell the real story simply — where you were, who was present, and roughly when. Small honest details are more convincing than a polished script, and your spouse should tell it the same way.',
 'Hãy kể lại câu chuyện thật một cách đơn giản — anh/chị đã ở đâu, có ai ở đó, và khoảng thời gian nào. Những chi tiết thật nhỏ nhặt thuyết phục hơn một câu chuyện dàn dựng, và vợ/chồng anh/chị nên kể giống như vậy.'),

('marriage', 'question', 'How long did you know each other before you got married?', 'Anh/chị quen biết nhau bao lâu trước khi kết hôn?',
 'Give the honest timeline. A short courtship is not disqualifying, but be ready to explain how your relationship developed so quickly and consistently with your spouse.',
 'Hãy nêu mốc thời gian trung thực. Quen biết ngắn không khiến hồ sơ bị từ chối, nhưng hãy sẵn sàng giải thích vì sao mối quan hệ phát triển nhanh như vậy, và khớp với lời vợ/chồng.'),

('marriage', 'question', 'Who introduced you, or how were you first introduced?', 'Ai đã giới thiệu hai người, hoặc hai người quen nhau lần đầu như thế nào?',
 'Name the person or setting (a friend, family, work, an app, an event). Keep it factual and consistent — this is an easy detail for both of you to remember the same way.',
 'Hãy nêu tên người hoặc hoàn cảnh (bạn bè, gia đình, nơi làm việc, ứng dụng, một sự kiện). Trả lời đúng sự thật và nhất quán — đây là chi tiết dễ để cả hai nhớ giống nhau.'),

('marriage', 'question', 'Before marriage, how often did you see each other in person?', 'Trước khi kết hôn, hai người gặp nhau trực tiếp thường xuyên như thế nào?',
 'Describe your real pattern of visits. If you lived apart or in different countries, be ready to show travel records or messages that back up what you say.',
 'Hãy mô tả tần suất gặp nhau thực tế. Nếu hai người sống xa nhau hoặc ở các nước khác nhau, hãy sẵn sàng cho xem hồ sơ đi lại hoặc tin nhắn để chứng minh.'),

('marriage', 'question', 'What did you and your spouse have for dinner last night?', 'Tối qua anh/chị và vợ/chồng đã ăn gì cho bữa tối?',
 'Just answer honestly about your real evening. Officers ask everyday questions like this to see whether you actually share a daily life together.',
 'Hãy trả lời trung thực về buổi tối thật của anh/chị. Viên chức hỏi những câu đời thường như vậy để xem hai người có thật sự chung sống hằng ngày hay không.'),

('marriage', 'question', 'What did you and your spouse do together last weekend?', 'Cuối tuần trước anh/chị và vợ/chồng đã làm gì cùng nhau?',
 'Describe what you actually did, even if it was ordinary (errands, cooking, visiting family). Consistency with your spouse matters more than having an exciting story.',
 'Hãy mô tả những gì hai người thật sự đã làm, dù bình thường (đi việc vặt, nấu ăn, thăm gia đình). Sự nhất quán với vợ/chồng quan trọng hơn một câu chuyện hấp dẫn.'),

('marriage', 'question', 'What time does your spouse usually wake up and go to sleep?', 'Vợ/chồng anh/chị thường thức dậy và đi ngủ lúc mấy giờ?',
 'Give their real schedule. Couples who live together know each other''s daily rhythm, so answer naturally rather than guessing.',
 'Hãy nêu lịch sinh hoạt thật của họ. Các cặp sống chung đều biết nhịp sinh hoạt của nhau, nên hãy trả lời tự nhiên thay vì đoán.'),

('marriage', 'question', 'Who usually drives, and what vehicles do you own?', 'Ai thường lái xe, và gia đình anh/chị có những xe nào?',
 'Describe your cars (make, color) and who drives them. If neither of you drives, explain how you get around — either answer is fine as long as it is true and matches.',
 'Hãy mô tả xe của anh/chị (hãng, màu) và ai lái. Nếu cả hai không lái xe, hãy giải thích cách đi lại — câu trả lời nào cũng được miễn là đúng và khớp nhau.'),

('marriage', 'question', 'How many bedrooms and bathrooms are in your home?', 'Nhà anh/chị có mấy phòng ngủ và mấy phòng tắm?',
 'Answer accurately — this is a simple fact both spouses should know. Officers often follow up on the home layout to test whether you really live there together.',
 'Hãy trả lời chính xác — đây là chi tiết đơn giản mà cả hai vợ chồng đều biết. Viên chức thường hỏi thêm về bố trí nhà để kiểm tra hai người có thật sự sống chung không.'),

('marriage', 'question', 'Describe the layout of your home and which side of the bed each of you sleeps on.', 'Hãy mô tả bố trí nhà và mỗi người ngủ ở bên nào của giường.',
 'Walk through the rooms as they really are and answer the sleeping-side question plainly. These small domestic details are hard to fake and easy to get right if you truly live together.',
 'Hãy mô tả các phòng đúng như thực tế và trả lời thẳng câu hỏi về bên ngủ. Những chi tiết sinh hoạt nhỏ này khó bịa và dễ trả lời đúng nếu hai người thật sự sống chung.'),

('marriage', 'question', 'Do you have any pets? What are their names?', 'Anh/chị có nuôi thú cưng không? Tên chúng là gì?',
 'Answer truthfully. If you have pets, both of you should know their names and who cares for them; if not, simply say so.',
 'Hãy trả lời trung thực. Nếu có nuôi thú cưng, cả hai nên biết tên và ai chăm sóc; nếu không, chỉ cần nói không.'),

('marriage', 'question', 'Who does the laundry, takes out the trash, and handles other household chores?', 'Ai giặt giũ, đổ rác, và làm các việc nhà khác?',
 'Describe how you actually split chores. There is no right answer — the point is that your description matches your spouse''s.',
 'Hãy mô tả cách hai người thật sự chia việc nhà. Không có câu trả lời đúng — điều quan trọng là mô tả của anh/chị khớp với vợ/chồng.'),

('marriage', 'question', 'How much is your monthly rent or mortgage payment?', 'Tiền thuê nhà hoặc trả góp mua nhà hằng tháng của anh/chị là bao nhiêu?',
 'Know the amount and who pays it. Being off by a little is normal, but you should be in the same range as your spouse.',
 'Hãy biết số tiền và ai trả. Chênh lệch một chút là bình thường, nhưng con số của anh/chị nên gần với vợ/chồng.'),

('marriage', 'question', 'Which utility bills do you have, and whose name is on them?', 'Anh/chị có những hóa đơn tiện ích nào, và mang tên ai?',
 'List your real bills (electricity, water, gas, internet) and whose name each is under. Bills in both names, or in each name, are useful evidence of a shared household.',
 'Hãy liệt kê các hóa đơn thật (điện, nước, gas, internet) và mỗi cái mang tên ai. Hóa đơn mang tên cả hai, hoặc mỗi người một số, là bằng chứng hữu ích cho việc chung sống.'),

('marriage', 'question', 'Do you and your spouse file your income taxes jointly?', 'Anh/chị và vợ/chồng có khai thuế thu nhập chung không?',
 'Answer accurately. Filing jointly is strong evidence of a shared life; if you filed separately, be ready to explain why.',
 'Hãy trả lời chính xác. Khai thuế chung là bằng chứng mạnh cho cuộc sống chung; nếu khai riêng, hãy sẵn sàng giải thích lý do.'),

('marriage', 'question', 'What are the names of your spouse''s parents?', 'Tên cha mẹ của vợ/chồng anh/chị là gì?',
 'Know your in-laws'' names. It is a basic detail that shows genuine involvement in each other''s families.',
 'Hãy biết tên cha mẹ vợ/chồng. Đây là chi tiết cơ bản cho thấy anh/chị thật sự gắn bó với gia đình của nhau.'),

('marriage', 'question', 'Does your spouse have brothers or sisters? What are their names?', 'Vợ/chồng anh/chị có anh chị em không? Tên họ là gì?',
 'Name the siblings you know and roughly how they fit in the family. If it is a large family, knowing the main ones is enough.',
 'Hãy nêu tên các anh chị em mà anh/chị biết và vị trí của họ trong gia đình. Nếu gia đình đông, biết những người chính là đủ.'),

('marriage', 'question', 'What are your spouse''s hobbies or interests?', 'Sở thích của vợ/chồng anh/chị là gì?',
 'Mention a few things they genuinely enjoy. Real, specific details (a sport, a show, cooking) are more convincing than generic answers.',
 'Hãy nêu vài điều mà họ thật sự yêu thích. Chi tiết thật, cụ thể (một môn thể thao, một chương trình, nấu ăn) thuyết phục hơn câu trả lời chung chung.'),

('marriage', 'question', 'What is your spouse''s favorite food or dish?', 'Món ăn yêu thích của vợ/chồng anh/chị là gì?',
 'Answer with something true. Everyday questions like this test whether you know each other the way a married couple would.',
 'Hãy trả lời điều gì đó đúng thật. Những câu đời thường như vậy kiểm tra xem hai người có hiểu nhau như một cặp vợ chồng không.'),

('marriage', 'question', 'Does your spouse have any medical conditions or take any regular medications?', 'Vợ/chồng anh/chị có bệnh lý gì hoặc dùng thuốc thường xuyên không?',
 'Share what you honestly know about their health. Spouses who live together are usually aware of major conditions or daily medications.',
 'Hãy chia sẻ những gì anh/chị thật sự biết về sức khỏe của họ. Vợ chồng sống chung thường biết về các bệnh lý quan trọng hoặc thuốc dùng hằng ngày.'),

('marriage', 'question', 'What language do you and your spouse speak at home?', 'Ở nhà anh/chị và vợ/chồng nói chuyện bằng ngôn ngữ nào?',
 'Answer honestly. If you speak different first languages, explain how you communicate — this is a common and acceptable situation as long as your accounts match.',
 'Hãy trả lời trung thực. Nếu hai người có tiếng mẹ đẻ khác nhau, hãy giải thích cách giao tiếp — đây là tình huống phổ biến và chấp nhận được miễn là lời kể của hai người khớp nhau.'),

('marriage', 'question', 'When is your spouse''s birthday, and how did you celebrate the last one?', 'Sinh nhật vợ/chồng anh/chị là ngày nào, và lần gần nhất đã tổ chức ra sao?',
 'Know the date and describe what you actually did. A simple honest celebration story is fine — consistency with your spouse is what matters.',
 'Hãy biết ngày sinh và mô tả những gì hai người thật sự đã làm. Một câu chuyện mừng sinh nhật đơn giản, chân thật là ổn — quan trọng là khớp với vợ/chồng.'),

('marriage', 'question', 'What did you give each other for your last anniversary or holiday?', 'Dịp kỷ niệm hoặc lễ gần nhất, hai người đã tặng nhau gì?',
 'Answer truthfully, even if the gift was small or you simply spent time together. Officers are checking for a shared life, not expensive gifts.',
 'Hãy trả lời trung thực, dù món quà nhỏ hay chỉ đơn giản là dành thời gian bên nhau. Viên chức kiểm tra cuộc sống chung, không phải quà đắt tiền.'),

('marriage', 'question', 'What is your and your spouse''s usual morning routine?', 'Thói quen buổi sáng thường ngày của anh/chị và vợ/chồng là gì?',
 'Describe how your mornings really go — who gets up first, who makes coffee, how you leave for the day. Natural detail here is very convincing.',
 'Hãy mô tả buổi sáng thật của hai người — ai dậy trước, ai pha cà phê, hai người rời nhà thế nào. Chi tiết tự nhiên ở đây rất thuyết phục.'),

('marriage', 'question', 'Who does the grocery shopping, and where do you usually shop?', 'Ai đi chợ/siêu thị, và anh/chị thường mua sắm ở đâu?',
 'Name your regular store and who usually goes. It is a small, verifiable detail about your shared routine.',
 'Hãy nêu cửa hàng quen và ai thường đi. Đây là chi tiết nhỏ, có thể kiểm chứng về sinh hoạt chung của hai người.'),

('marriage', 'question', 'Have you met your spouse''s extended family? Whom have you met?', 'Anh/chị đã gặp gia đình mở rộng của vợ/chồng chưa? Đã gặp những ai?',
 'Describe who you have met and when. If distance or immigration status has prevented meeting some relatives, explain that honestly.',
 'Hãy mô tả anh/chị đã gặp ai và khi nào. Nếu khoảng cách hoặc tình trạng di trú khiến chưa gặp được một số người thân, hãy giải thích trung thực.'),

('marriage', 'question', 'What is your spouse''s immigration or citizenship status?', 'Tình trạng di trú hoặc quốc tịch của vợ/chồng anh/chị là gì?',
 'Know whether your spouse is a U.S. citizen or lawful permanent resident, since it affects your case. This is basic information you should have clearly.',
 'Hãy biết vợ/chồng anh/chị là công dân Hoa Kỳ hay thường trú nhân hợp pháp, vì điều này ảnh hưởng đến hồ sơ. Đây là thông tin cơ bản anh/chị cần nắm rõ.'),

('marriage', 'question', 'Have you lived at any other addresses together? Where?', 'Hai người đã từng sống ở địa chỉ nào khác cùng nhau chưa? Ở đâu?',
 'List your previous shared addresses in order. Being able to trace your housing history together supports a genuine, ongoing relationship.',
 'Hãy liệt kê các địa chỉ từng sống chung theo thứ tự. Việc kể được lịch sử nơi ở chung củng cố cho một mối quan hệ thật và liên tục.'),

('marriage', 'question', 'How did you get to the interview today, and who came with you?', 'Hôm nay anh/chị đến buổi phỏng vấn bằng cách nào, và ai đi cùng?',
 'Answer simply and truthfully. It is a warm-up question — there is no wrong way to arrive, so just relax and reply naturally.',
 'Hãy trả lời đơn giản và trung thực. Đây là câu hỏi khởi động — không có cách đến nào là sai, nên cứ thoải mái trả lời tự nhiên.'),

('marriage', 'question', 'What religion, if any, do you and your spouse practice, and do you attend services together?', 'Anh/chị và vợ/chồng theo tôn giáo nào (nếu có), và có cùng đi lễ/sinh hoạt không?',
 'Answer honestly, whether you share a religion, have different ones, or none. If you attend services or celebrate holidays together, mention it as part of your shared life.',
 'Hãy trả lời trung thực, dù hai người cùng tôn giáo, khác tôn giáo, hay không theo tôn giáo nào. Nếu cùng đi lễ hoặc mừng các dịp lễ, hãy nêu ra như một phần của cuộc sống chung.'),

('marriage', 'question', 'What is your spouse''s highest level of education, and where did they study?', 'Trình độ học vấn cao nhất của vợ/chồng anh/chị là gì, và họ học ở đâu?',
 'Share what you know about their schooling. It is a normal detail that a spouse would generally be aware of.',
 'Hãy chia sẻ những gì anh/chị biết về việc học của họ. Đây là chi tiết bình thường mà một người bạn đời thường biết.'),

('marriage', 'question', 'How do you and your spouse handle disagreements about money or family?', 'Anh/chị và vợ/chồng giải quyết bất đồng về tiền bạc hoặc gia đình như thế nào?',
 'Describe honestly how you work through conflict. Showing that you resolve normal disagreements together reflects a real relationship.',
 'Hãy mô tả trung thực cách hai người vượt qua mâu thuẫn. Việc cùng nhau giải quyết những bất đồng bình thường phản ánh một mối quan hệ thật.'),

('marriage', 'question', 'What are the ages and names of any children — yours, your spouse''s, or from previous relationships?', 'Tên và tuổi của các con — của anh/chị, của vợ/chồng, hoặc từ quan hệ trước — là gì?',
 'Be accurate about all children in the household, including step-children. Officers may ask about the whole family, so know everyone''s names and ages.',
 'Hãy trả lời chính xác về tất cả các con trong nhà, kể cả con riêng. Viên chức có thể hỏi về cả gia đình, nên hãy biết tên và tuổi của mọi người.'),

('marriage', 'question', 'What do you love or admire most about your spouse?', 'Điều anh/chị yêu quý hoặc ngưỡng mộ nhất ở vợ/chồng là gì?',
 'Answer from the heart in your own words. A sincere, specific answer comes across as genuine — there is no need to memorize anything.',
 'Hãy trả lời bằng chính lời của mình, từ trái tim. Một câu trả lời chân thành, cụ thể sẽ rất tự nhiên — không cần học thuộc gì cả.'),

('marriage', 'question', 'Where does your spouse work now, and what are their usual hours?', 'Hiện vợ/chồng anh/chị làm việc ở đâu, và giờ làm thường lệ ra sao?',
 'Know their employer, role, and general schedule. This overlaps with daily-life questions, so your answer should line up with what your spouse says.',
 'Hãy biết nơi làm việc, công việc, và lịch làm chung của họ. Câu này liên quan đến các câu về sinh hoạt hằng ngày, nên câu trả lời của anh/chị phải khớp với vợ/chồng.'),

('marriage', 'question', 'What is your spouse''s phone number, and how do you usually reach each other during the day?', 'Số điện thoại của vợ/chồng anh/chị là gì, và ban ngày hai người thường liên lạc bằng cách nào?',
 'You should know your spouse''s number and how you stay in touch (calls, texts, an app). It is a basic sign of an ongoing daily relationship.',
 'Anh/chị nên biết số điện thoại của vợ/chồng và cách hai người giữ liên lạc (gọi điện, nhắn tin, một ứng dụng). Đây là dấu hiệu cơ bản của một mối quan hệ thường ngày.');

-- 3. Marriage RED FLAGS — common mistakes and warning signs officers watch
--    for. Here question_* states the risk; answer_* explains why it matters and
--    how to handle it honestly.
insert into questions (category, content_type, question_en, question_vi, answer_en, answer_vi) values

('marriage', 'red_flag', 'Giving answers that don''t match your spouse''s', 'Trả lời không khớp với vợ/chồng',
 'Inconsistent answers about daily life, finances, or how you met are the single biggest reason for suspicion. You cannot memorize a whole life — instead, review your real routines together beforehand and, if you don''t know something, say so honestly rather than guess.',
 'Trả lời không khớp về sinh hoạt hằng ngày, tài chính, hay cách quen nhau là lý do gây nghi ngờ lớn nhất. Anh/chị không thể học thuộc cả một cuộc sống — thay vào đó hãy cùng ôn lại các thói quen thật, và nếu không biết điều gì, hãy nói thật thay vì đoán.'),

('marriage', 'red_flag', 'Little or no evidence of living together', 'Ít hoặc không có bằng chứng sống chung',
 'No joint lease, shared bills, or mail at the same address raises doubt. Build a paper trail over time — add both names to a lease, bills, and accounts, and keep mail addressed to each of you at your shared home.',
 'Không có hợp đồng thuê chung, hóa đơn chung, hay thư từ cùng địa chỉ sẽ gây nghi ngờ. Hãy tạo bằng chứng giấy tờ theo thời gian — thêm tên cả hai vào hợp đồng thuê, hóa đơn, tài khoản, và giữ thư từ gửi cho mỗi người tại nhà chung.'),

('marriage', 'red_flag', 'Married very soon after meeting or right before filing', 'Kết hôn ngay sau khi quen hoặc ngay trước khi nộp hồ sơ',
 'A very fast marriage isn''t forbidden, but it draws scrutiny. Be ready to explain your timeline naturally and back it up with evidence the relationship is real and ongoing.',
 'Kết hôn rất nhanh không bị cấm, nhưng sẽ bị xem xét kỹ. Hãy sẵn sàng giải thích mốc thời gian một cách tự nhiên và chứng minh mối quan hệ là thật và tiếp diễn.'),

('marriage', 'red_flag', 'No joint finances at all', 'Hoàn toàn không có tài chính chung',
 'Completely separate money with nothing shared can look like a business arrangement. Where it makes sense, share at least some finances — a joint account, shared bills, or naming each other on insurance or beneficiaries.',
 'Tiền bạc hoàn toàn tách biệt, không chia sẻ gì có thể trông giống một thỏa thuận. Khi hợp lý, hãy chia sẻ ít nhất một phần tài chính — tài khoản chung, hóa đơn chung, hoặc ghi tên nhau trên bảo hiểm hay người thụ hưởng.'),

('marriage', 'red_flag', 'Answers that sound memorized or rehearsed', 'Câu trả lời nghe như học thuộc lòng',
 'Robotic, scripted answers make officers suspect coaching. Don''t memorize lines — know your real life and answer conversationally, the way you would tell a friend.',
 'Câu trả lời máy móc, như đọc bài khiến viên chức nghi ngờ có sự dàn dựng. Đừng học thuộc — hãy nắm rõ cuộc sống thật và trả lời tự nhiên như kể cho một người bạn.'),

('marriage', 'red_flag', 'Guessing instead of saying "I don''t know"', 'Đoán bừa thay vì nói "Tôi không biết"',
 'A wrong guess that contradicts your spouse is worse than admitting you don''t know a detail. It is perfectly acceptable to say you''re not sure — honesty is more credible than a confident wrong answer.',
 'Một câu đoán sai mâu thuẫn với vợ/chồng còn tệ hơn việc thừa nhận không biết. Nói rằng mình không chắc là hoàn toàn chấp nhận được — sự trung thực đáng tin hơn một câu trả lời sai đầy tự tin.'),

('marriage', 'red_flag', 'Your spouse''s family doesn''t know about the marriage', 'Gia đình vợ/chồng không biết về cuộc hôn nhân',
 'If close family is unaware you''re married, officers wonder why. There can be legitimate reasons, but be prepared to explain, and ideally show that at least some family and friends know and support the relationship.',
 'Nếu người thân gần gũi không biết anh/chị đã kết hôn, viên chức sẽ thắc mắc. Có thể có lý do chính đáng, nhưng hãy sẵn sàng giải thích, và tốt nhất là cho thấy ít nhất một số người thân, bạn bè biết và ủng hộ mối quan hệ.'),

('marriage', 'red_flag', 'Big gaps in your relationship timeline you can''t explain', 'Những khoảng trống trong dòng thời gian quan hệ mà anh/chị không giải thích được',
 'Unexplained gaps — long periods with no contact or evidence — invite doubt. Keep a simple timeline of your relationship and be ready to account for any long separations with travel records or messages.',
 'Những khoảng trống không giải thích được — thời gian dài không liên lạc hay không có bằng chứng — gây nghi ngờ. Hãy giữ một dòng thời gian đơn giản về mối quan hệ và sẵn sàng giải thích các lần xa cách dài bằng hồ sơ đi lại hoặc tin nhắn.'),

('marriage', 'red_flag', 'Only posed photos, or photos all from one occasion', 'Chỉ có ảnh chụp dàn dựng, hoặc ảnh đều từ một dịp',
 'A handful of staged photos from a single day is weak evidence. Bring photos spread across time and settings — trips, holidays, everyday moments, and time with each other''s families.',
 'Vài tấm ảnh dàn dựng trong một ngày là bằng chứng yếu. Hãy mang ảnh trải dài theo thời gian và hoàn cảnh — các chuyến đi, dịp lễ, khoảnh khắc đời thường, và thời gian bên gia đình của nhau.'),

('marriage', 'red_flag', 'Being unable to describe your own home', 'Không mô tả được chính ngôi nhà của mình',
 'Not knowing your home''s layout, furniture, or which side of the bed you sleep on is a classic warning sign. If you truly live together this is easy — walk through your home in your mind before the interview.',
 'Không biết bố trí nhà, đồ đạc, hay mình ngủ bên nào của giường là dấu hiệu cảnh báo điển hình. Nếu thật sự sống chung thì điều này rất dễ — hãy hình dung lại ngôi nhà của mình trước buổi phỏng vấn.'),

('marriage', 'red_flag', 'A prior petition, quick divorce, or immigration history that looks arranged', 'Từng có hồ sơ bảo lãnh, ly hôn nhanh, hoặc lịch sử di trú trông giống sắp đặt',
 'Previous marriage-based petitions or a fast prior divorce can trigger extra scrutiny. Be upfront about your history and ready to document that your prior relationships and this one are genuine.',
 'Các hồ sơ bảo lãnh diện hôn nhân trước đây hoặc một cuộc ly hôn nhanh có thể khiến hồ sơ bị xem xét thêm. Hãy thẳng thắn về quá khứ và sẵn sàng chứng minh cả quan hệ trước và hiện tại đều là thật.'),

('marriage', 'red_flag', 'Letting nerves turn into changing your story', 'Để sự lo lắng khiến anh/chị thay đổi lời kể',
 'Nervousness is normal and officers expect it — but changing details when pressed looks like dishonesty. Slow down, breathe, stick to the truth, and ask for a question to be repeated if you need to.',
 'Lo lắng là bình thường và viên chức biết điều đó — nhưng thay đổi chi tiết khi bị hỏi dồn trông giống thiếu trung thực. Hãy chậm lại, hít thở, giữ đúng sự thật, và xin nhắc lại câu hỏi nếu cần.');

-- 4. Marriage DOCUMENT CHECKLIST — what to bring. question_* is the item;
--    answer_* explains why it matters / a practical tip.
insert into questions (category, content_type, question_en, question_vi, answer_en, answer_vi) values

('marriage', 'checklist', 'Government photo ID and passports for both spouses', 'Giấy tờ tùy thân có ảnh và hộ chiếu của cả hai vợ chồng',
 'Bring valid IDs, passports, and any current work permit or green card. The officer verifies identity first, so have these ready on top.',
 'Hãy mang theo giấy tờ tùy thân hợp lệ, hộ chiếu, và bất kỳ giấy phép làm việc hay thẻ xanh hiện có. Viên chức xác minh danh tính trước tiên, nên hãy để sẵn những thứ này trên cùng.'),

('marriage', 'checklist', 'Your interview appointment notice', 'Thư hẹn phỏng vấn của anh/chị',
 'Bring the original appointment letter (Form I-797C or the interview notice). You may not be allowed in without it.',
 'Hãy mang theo thư hẹn gốc (Mẫu I-797C hoặc thư hẹn phỏng vấn). Có thể anh/chị sẽ không được vào nếu thiếu.'),

('marriage', 'checklist', 'Marriage certificate', 'Giấy chứng nhận kết hôn',
 'Bring the original plus a copy. This is the core document proving your marriage exists.',
 'Hãy mang bản gốc kèm một bản sao. Đây là giấy tờ cốt lõi chứng minh cuộc hôn nhân của anh/chị.'),

('marriage', 'checklist', 'Proof of ending any prior marriages', 'Bằng chứng chấm dứt các cuộc hôn nhân trước',
 'If either of you was married before, bring divorce decrees or death certificates. Your current marriage must be legally valid.',
 'Nếu một trong hai từng kết hôn, hãy mang bản án ly hôn hoặc giấy chứng tử. Cuộc hôn nhân hiện tại phải hợp pháp.'),

('marriage', 'checklist', 'Joint lease, mortgage, or property deed', 'Hợp đồng thuê nhà chung, giấy vay mua nhà, hoặc giấy tờ nhà đất',
 'Documents showing you live at the same address, ideally in both names, are among the strongest evidence of a shared life.',
 'Giấy tờ cho thấy hai người sống cùng địa chỉ, lý tưởng là mang tên cả hai, là một trong những bằng chứng mạnh nhất về cuộc sống chung.'),

('marriage', 'checklist', 'Joint bank and credit card statements', 'Sao kê ngân hàng và thẻ tín dụng chung',
 'Statements from joint accounts show combined finances. Bring several months if you have them, not just one.',
 'Sao kê từ tài khoản chung cho thấy tài chính gộp chung. Hãy mang nhiều tháng nếu có, không chỉ một tháng.'),

('marriage', 'checklist', 'Joint utility bills', 'Hóa đơn tiện ích chung',
 'Electricity, water, gas, internet, or phone bills at your shared address help prove you actually live together.',
 'Hóa đơn điện, nước, gas, internet, hay điện thoại tại địa chỉ chung giúp chứng minh hai người thật sự sống cùng nhau.'),

('marriage', 'checklist', 'Health, auto, or life insurance naming each other', 'Bảo hiểm y tế, xe, hoặc nhân thọ có ghi tên nhau',
 'Policies where you list each other as spouse or beneficiary are strong evidence of an intertwined life.',
 'Các hợp đồng bảo hiểm ghi tên nhau là vợ/chồng hoặc người thụ hưởng là bằng chứng mạnh cho một cuộc sống gắn kết.'),

('marriage', 'checklist', 'Joint federal tax returns', 'Tờ khai thuế liên bang chung',
 'Filing "married filing jointly" is persuasive. Bring your most recent returns and W-2s.',
 'Khai thuế theo diện "vợ chồng khai chung" rất thuyết phục. Hãy mang các tờ khai gần nhất và mẫu W-2.'),

('marriage', 'checklist', 'Photos together across time', 'Ảnh chụp cùng nhau qua thời gian',
 'Bring a selection spanning your relationship — dating, wedding, trips, holidays, and time with each other''s families — not just wedding photos.',
 'Hãy mang một số ảnh trải dài suốt mối quan hệ — lúc hẹn hò, đám cưới, các chuyến đi, dịp lễ, và thời gian bên gia đình của nhau — không chỉ ảnh cưới.'),

('marriage', 'checklist', 'Birth certificates of children you have together', 'Giấy khai sinh của con chung',
 'If you have children together, their birth certificates listing both parents are powerful evidence of a bona fide marriage.',
 'Nếu có con chung, giấy khai sinh ghi tên cả cha lẫn mẹ là bằng chứng rất mạnh cho một cuộc hôn nhân chân thật.'),

('marriage', 'checklist', 'Affidavits from people who know you as a couple', 'Bản tuyên thệ từ những người biết hai người là một cặp',
 'Signed letters from friends or family who can attest to your relationship add support. Bring their contact details too.',
 'Thư có chữ ký từ bạn bè hoặc người thân có thể xác nhận mối quan hệ sẽ củng cố hồ sơ. Hãy mang cả thông tin liên lạc của họ.'),

('marriage', 'checklist', 'Evidence of trips taken together', 'Bằng chứng các chuyến đi cùng nhau',
 'Boarding passes, hotel bookings, and passport stamps from shared travel help document your relationship over time.',
 'Vé máy bay, đặt phòng khách sạn, và dấu mộc hộ chiếu từ các chuyến đi chung giúp chứng minh mối quan hệ theo thời gian.'),

('marriage', 'checklist', 'Originals plus copies, organized and labeled', 'Bản gốc kèm bản sao, sắp xếp và ghi nhãn rõ ràng',
 'Bring originals for the officer to see and copies to hand over. Organizing documents by type makes the interview go faster and smoother.',
 'Hãy mang bản gốc để viên chức xem và bản sao để nộp. Sắp xếp giấy tờ theo từng loại giúp buổi phỏng vấn diễn ra nhanh và suôn sẻ hơn.');
