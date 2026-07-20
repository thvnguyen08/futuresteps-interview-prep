/* ════════════════════════════════════════════════
   INTERVIEW PREP — MAIN SCRIPT
   ════════════════════════════════════════════════ */

/* ── Supabase config ──
   Fill these in with your project's URL and public "anon" key
   (Supabase dashboard → Project Settings → API). The anon key is safe
   to expose in client-side code as long as row-level security is on
   and the "questions" table only has a public SELECT policy. */
const SUPABASE_URL = "https://ltxvztppdwbptmsqavty.supabase.co";
const SUPABASE_ANON_KEY = "sb_publishable_n-QM-NEws8MJZ6JXqv6_qQ_F32avzuE";

let supabaseClient = null;
try {
  supabaseClient = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
} catch (err) {
  console.error("Failed to create Supabase client — check SUPABASE_URL/SUPABASE_ANON_KEY in script.js:", err);
}

/* Local development (localhost preview) still READS prod data, but never writes
   analytics/activity/identity rows to it — keeps test sessions out of the CRM. */
const IS_DEV_HOST = /^(localhost|127\.0\.0\.1)$/.test(window.location.hostname);

/* ── Translations (static UI strings only; question/answer text comes
   from the database's *_en / *_vi columns) ── */
const translations = {
  vi: {
    "header.subtitle": "Ôn Phỏng Vấn",
    "intro.tag": "Hành Trình Của Bạn Bắt Đầu Từ Đây",
    "intro.title": 'Chuẩn Bị Cho <em>Buổi Phỏng Vấn Di Trú</em> Của Bạn',
    "intro.desc": "Luyện tập với các câu hỏi mà viên chức thường hỏi. Chọn một danh mục, tự kiểm tra, và xem gợi ý hoặc đáp án khi bạn sẵn sàng.",
    "cta.title": "Dùng nhiều thiết bị?",
    "cta.sub": "Tiến trình của bạn đã được lưu trên thiết bị này. Chỉ cần đăng nhập bằng email nếu bạn muốn đồng bộ trên điện thoại, máy tính bảng và máy tính — hoàn toàn tùy chọn.",
    "cta.btn": '<i class="fa-regular fa-envelope"></i> Đồng Bộ Thiết Bị',
    "siteCta.title": "Cần hỗ trợ thật sự cho hồ sơ của bạn?",
    "siteCta.sub": "Hãy cho chúng tôi biết bạn đang cần dịch vụ gì — Future Steps Services sẽ đồng hành cùng bạn ở từng bước.",
    "siteCta.btn": '<i class="fa-solid fa-arrow-up-right-from-square"></i> Ghé Thăm Trang Web',
    "cat.marriage": "Thẻ Xanh Diện Hôn Nhân",
    "cat.naturalization": "Thi Quốc Tịch",
    "cat.asylum": "Phỏng Vấn Tị Nạn",
    "cat.f1": "Visa Du Học F-1",
    "cat.b1b2": "Visa Du Lịch/Công Tác B1/B2",
    "cat.flagged": "Đã Đánh Dấu",
    "content.questions": "Câu Hỏi Luyện Tập",
    "content.greenFlags": "Điều Nên Làm",
    "content.redFlags": "Điều Cần Tránh",
    "content.documents": "Giấy Tờ Cần Mang",
    "content.badge.green_flag": " — Điều Nên Làm",
    "content.badge.red_flag": " — Điều Cần Tránh",
    "content.badge.checklist": " — Giấy Tờ",
    "content.answerLabel.green_flag": "Vì Sao Có Lợi / Cách Thể Hiện",
    "content.answerLabel.red_flag": "Vì Sao Quan Trọng / Cách Xử Lý",
    "content.answerLabel.checklist": "Vì Sao Cần Thiết",
    "content.progress.green_flag": "Điều nên làm {current}/{total}",
    "content.progress.red_flag": "Điều cần tránh {current}/{total}",
    "content.progress.checklist": "Giấy tờ {current}/{total}",
    "home.prompt": "Bạn đang cần dịch vụ nào?",
    "home.back": "Trang Chủ",
    "progress.title": "Tiến trình của bạn",
    "progress.sub": "Qua {rounds} lượt luyện tập",
    "progress.correct": "Đúng",
    "progress.wrong": "Sai",
    "progress.rounds": "Lượt luyện",
    "progress.reviewed": "Đã ôn",
    "progress.accuracy": "Độ chính xác",
    "progress.byCategory": "Luyện theo chủ đề",
    "state.loading": "Đang tải câu hỏi…",
    "state.error": "Không thể tải ngân hàng câu hỏi. Hãy đảm bảo URL và khóa Supabase đã được thiết lập trong <code>script.js</code>, và cơ sở dữ liệu đã có dữ liệu.",
    "state.done": "Bạn đã hoàn thành tất cả câu hỏi trong lượt này. Làm tốt lắm!",
    "state.done.flagged": "Bạn chưa đánh dấu câu hỏi nào để ôn lại. Bấm vào ngôi sao trên bất kỳ câu hỏi nào để lưu lại ở đây.",
    "btn.reveal": "Xem Đáp Án",
    "btn.next": 'Câu Tiếp Theo <i class="fa-solid fa-arrow-right"></i>',
    "btn.restart": '<i class="fa-solid fa-rotate-right"></i> Bắt Đầu Lại',
    "btn.gotIt": '<i class="fa-solid fa-check"></i> Tôi Biết Đáp Án',
    "btn.missed": '<i class="fa-solid fa-xmark"></i> Tôi Trả Lời Sai',
    "btn.playSentence": "Phát Câu",
    "footer.note": 'Đây chỉ là tài liệu luyện tập, không phải tư vấn pháp lý. Để được hướng dẫn cụ thể cho trường hợp của bạn, hãy liên hệ trực tiếp với Future Steps Services, hoặc gửi email đến <a href="mailto:futuresteps.dallas@gmail.com">futuresteps.dallas@gmail.com</a>.',
    "badge.marriage": "Thẻ Xanh Diện Hôn Nhân",
    "badge.naturalization": "Thi Quốc Tịch",
    "badge.asylum": "Phỏng Vấn Tị Nạn",
    "badge.f1": "Visa Du Học F-1",
    "badge.b1b2": "Visa Du Lịch/Công Tác B1/B2",
    "badge.eng_speaking": "Thi Quốc Tịch — Thi Tiếng Anh (Nói)",
    "badge.eng_reading": "Thi Quốc Tịch — Thi Tiếng Anh (Đọc)",
    "badge.eng_writing": "Thi Quốc Tịch — Thi Tiếng Anh (Viết)",
    "answer.label.marriage": "Gợi Ý Trả Lời",
    "answer.label.asylum": "Gợi Ý Trả Lời",
    "answer.label.naturalization": "Đáp Án Chính Thức",
    "answer.label.f1": "Gợi Ý Trả Lời",
    "answer.label.b1b2": "Gợi Ý Trả Lời",
    "answer.label.eng_speaking": "Gợi Ý",
    "answer.label.eng_reading": "Gợi Ý Đọc",
    "answer.label.eng_writing": "Gợi Ý Viết",
    "progress": "Câu {current} / {total}",
    "flag.ariaLabel": "Đánh dấu để ôn lại",
    "sim.practice": '<i class="fa-solid fa-book-open"></i> Học Tất Cả 128 Câu',
    "sim.test": '<i class="fa-solid fa-stopwatch"></i> Mô Phỏng Thi Thật (20 Câu)',
    "sim.spoken": '<i class="fa-solid fa-microphone-lines"></i> Thi Nói (Tự Chấm Điểm)',
    "sim.review": "Ôn Câu Sai",
    "qa.title": "Thao Tác Nhanh",
    "qa.questions": "Câu Hỏi Luyện Tập",
    "qa.mock": "Phỏng Vấn Thử",
    "qa.docs": "Giấy Tờ Cần Mang",
    "qa.flash": "128 Câu Dân Sự",
    "qa.mctest": "Thi Dân Sự Như Thật",
    "qa.spoken": "Thi Nói Dân Sự",
    "qa.writing": "Thi Viết",
    "qa.speaking": "Thi Nói Tiếng Anh",
    "qa.reading": "Thi Đọc",
    "qa.review": "Ôn Câu Sai",
    "qa.green": "Điều Nên Làm",
    "qa.red": "Điều Cần Tránh",
    "flash.question": "Câu Hỏi",
    "flash.answer": "Trả Lời",
    "flash.hint": "Chạm để lật thẻ",
    "flash.sound": "Nghe",
    "flash.flip": "Lật Thẻ",
    "flash.prev": "Trước",
    "flash.next": "Tiếp",
    "news.label": "Tin Tức Di Trú Mới Nhất",
    "news.note": "Chạm vào tin để đọc thêm · cập nhật hàng tuần",
    "news.breaking": "Tin Nóng",
    "news.faqTitle": "Câu hỏi bạn có thể được hỏi về việc này",
    "news.faqNote": "Chỉ là tài liệu luyện tập — không phải tư vấn pháp lý. Hãy hỏi Future Steps về trường hợp của bạn.",
    "news.practiceHint": "câu hỏi luyện tập",
    "cd.prompt": "Buổi phỏng vấn của bạn là ngày nào?",
    "cd.save": "Lưu",
    "cd.skip": "Chưa có lịch — nhắc tôi sau",
    "cd.change": "Đổi ngày",
    "cd.clear": "Xóa",
    "mock.study": '<i class="fa-solid fa-book-open"></i> Học Câu Hỏi',
    "mock.interview": '<i class="fa-solid fa-microphone-lines"></i> Phỏng Vấn Thử · Ghi Âm & Nghe Lại',
    "mock.hear": "Nghe Câu Hỏi",
    "mock.record": "Ghi Âm Câu Trả Lời",
    "mock.recording": "Đang ghi âm…",
    "mock.stop": "Dừng",
    "mock.error": "Cần quyền truy cập micro để ghi âm. Vui lòng cho phép và thử lại.",
    "mock.redo": "Ghi Âm Lại",
    "mock.rateLabel": "Anh/chị thấy thế nào?",
    "mock.confident": '<i class="fa-solid fa-face-smile"></i> Tự Tin',
    "mock.okay": '<i class="fa-solid fa-face-meh"></i> Tạm Ổn',
    "mock.needsWork": '<i class="fa-solid fa-face-frown"></i> Cần Cải Thiện',
    "mock.tipsSummary": "Xem câu trả lời mẫu",
    "fb.eyebrow": "Hai câu hỏi nhanh nhé? (không bắt buộc)",
    "fb.qEase": "Ứng dụng có dễ dùng không?",
    "fb.easeLow": "Khó",
    "fb.easeHigh": "Rất dễ",
    "fb.qHelp": "Nó có giúp bạn chuẩn bị không?",
    "fb.helpLow": "Không hẳn",
    "fb.helpHigh": "Rất nhiều",
    "fb.qRecommend": "Bạn có giới thiệu FutureSteps cho bạn bè hoặc người thân không? <span class=\"feedback-opt\">(không bắt buộc)</span>",
    "fb.recLow": "Không giới thiệu",
    "fb.recHigh": "Chắc chắn",
    "fb.qComment": "Chúng tôi có thể cải thiện điều gì? <span class=\"feedback-opt\">(không bắt buộc)</span>",
    "fb.optional": "(không bắt buộc)",
    "fb.commentPh": "Bất cứ điều gì bạn muốn cho chúng tôi biết…",
    "fb.send": "Gửi Đánh Giá",
    "fb.skip": "Bỏ qua — tiếp tục luyện tập",
    "fb.thanks": "Cảm ơn bạn — điều này giúp chúng tôi cải thiện ứng dụng! 🙌",
    "fb.reopen": "★ Đánh giá ứng dụng",
    "review.badgeSuffix": " — Ôn Câu Sai",
    "review.done": "Đã ôn xong — anh/chị đã nắm được {cleared}/{total} câu. Còn {remaining} câu cần ôn.",
    "review.again": '<i class="fa-solid fa-rotate-right"></i> Ôn Lại',
    "spoken.repeat": "Nghe Câu Hỏi",
    "spoken.answer": "Trả Lời Bằng Giọng Nói",
    "spoken.listening": "Đang nghe… hãy nói câu trả lời của bạn",
    "spoken.youSaid": "Bạn đã nói:",
    "spoken.correct": "Đúng",
    "spoken.incorrect": "Sai",
    "spoken.verdict.pass": "✅ Nghe có vẻ đúng — hãy xác nhận hoặc chỉnh lại bên dưới.",
    "spoken.verdict.fail": "❌ Chưa khớp với đáp án chính thức — hãy xác nhận hoặc chỉnh lại bên dưới.",
    "spoken.verdict.manual": "Câu này không thể tự chấm — hãy nghe đáp án rồi tự chấm điểm.",
    "spoken.unsupported": "Trình duyệt này không hỗ trợ nhận diện giọng nói. Hãy dùng Chrome hoặc Edge trên máy tính, hoặc chọn Mô Phỏng Thi Thật để tự chấm.",
    "spoken.error": "Không nghe rõ. Hãy bấm micro thử lại, hoặc tự chấm điểm bên dưới.",
    "mc.prompt": "Chọn câu trả lời mà anh/chị cho là đúng:",
    "typed.placeholder": "Nhập câu trả lời của anh/chị…",
    "typed.submit": "Nộp",
    "typed.youTyped": "Anh/chị đã nhập:",
    "sim.progress": "Câu {current}/{total} · Đúng {correct}/{answered}",
    "sim.badgeSuffix": " — Mô Phỏng Thi",
    "sim.pass": "✅ ĐẠT — Trả lời đúng {correct}/{total} câu (cần tối thiểu {threshold}/20 để đậu bài thi thật)",
    "sim.fail": "❌ CHƯA ĐẠT — Trả lời đúng {correct}/{total} câu (cần tối thiểu {threshold}/20 để đậu bài thi thật)",
    "sim.timing": "Tổng thời gian: {total} · Trung bình: {avg}/câu",
    "btn.tryAgain": '<i class="fa-solid fa-rotate-right"></i> Thử Bộ Câu Hỏi Khác',
    "nat.civicsTest": '<i class="fa-solid fa-landmark"></i> Thi Dân Sự',
    "nat.englishTest": '<i class="fa-solid fa-comment-dots"></i> Thi Tiếng Anh',
    "eng.speaking": '<i class="fa-solid fa-microphone"></i> Nói',
    "eng.reading": '<i class="fa-solid fa-book"></i> Đọc',
    "eng.writing": '<i class="fa-solid fa-pen"></i> Viết',
    "eng.writingPrompt": "🔊 Nghe câu này rồi viết ra giấy. Bấm \"Xem Đáp Án\" để kiểm tra.",
    "eng.result.excellent": "🌟 Xuất Sắc — Đúng {pct}%. Bạn đã sẵn sàng cho phần thi tiếng Anh!",
    "eng.result.good": "👍 Khá Tốt — Đúng {pct}%. Hãy ôn lại thêm một chút trước buổi phỏng vấn.",
    "eng.result.needsPractice": "📚 Cần Luyện Thêm — Đúng {pct}%. Hãy luyện tập thêm phần nói, đọc và viết.",
    "account.login": "Đăng Nhập",
    "account.prompt": "Đăng nhập bằng email để lưu câu hỏi đã đánh dấu và kết quả luyện tập trên mọi thiết bị.",
    "account.notRegistered": "Hãy đăng ký từ màn hình bắt đầu để tạo hồ sơ của bạn.",
    "account.profileTitle": "Hồ Sơ Của Bạn",
    "account.signOut": "Đăng Xuất",
    "account.sendLink": "Gửi Liên Kết Đăng Nhập",
    "account.sentMsg": "Hãy kiểm tra email để nhận liên kết đăng nhập!",
    "account.error": "Có lỗi xảy ra. Vui lòng thử lại.",
    "account.logout": "Đăng Xuất",
    "account.recentResults": "Kết Quả Gần Đây",
    "account.noResults": "Chưa có kết quả luyện tập nào.",
    "account.phonePlaceholder": "Số điện thoại (không bắt buộc)",
    "account.savePhone": "Lưu Số Điện Thoại",
    "account.saveProfile": "Lưu",
    "account.statePlaceholder": "Tiểu bang (không bắt buộc)",
    "account.stateHint": "Chọn tiểu bang của bạn để xem đáp án đúng cho câu hỏi về Thống Đốc, Thượng Nghị Sĩ và thủ phủ tiểu bang trong phần Thi Dân Sự.",
    "account.phoneSaved": "Đã lưu!",
    "account.help": 'Cần hỗ trợ? Liên hệ chúng tôi qua <a href="mailto:futuresteps.dallas@gmail.com">futuresteps.dallas@gmail.com</a>',
    "gate.title": "Bắt đầu luyện tập — miễn phí",
    "gate.sub": "Luyện tập với những câu hỏi thật mà nhân viên thường hỏi — chọn bất kỳ chủ đề nào và bắt đầu chỉ với một chạm. Không cần tài khoản.",
    "loc.title": "Bạn sống ở tiểu bang nào?",
    "loc.sub": "Bài thi Quốc tịch (Civics) hỏi về các quan chức của chính tiểu bang bạn — thống đốc, thượng nghị sĩ và thủ phủ. Hãy cho biết tiểu bang để chúng tôi hỏi đúng đáp án.",
    "loc.start": "Bắt Đầu Luyện Quốc Tịch",
    "loc.back": "← Quay lại danh mục",
    "gate.contactHint": "Chúng tôi dùng thông tin này để Future Steps hỗ trợ hồ sơ của bạn. Không cần xác minh — bạn bắt đầu luyện tập ngay khi nhấn bên dưới.",
    "gate.locationHint": "Sống ngoài Hoa Kỳ? Hãy chọn Việt Nam hoặc Quốc gia khác — bạn vẫn luyện tập được mọi thứ.",
    "gate.start": "Bắt Đầu Luyện Tập",
    "cap.eyebrow": "Làm tốt lắm! 🎉",
    "cap.title": "Lưu tiến trình của bạn",
    "cap.sub": "Thêm email để chúng tôi lưu lại chỗ bạn đang học và gửi mẹo ôn thi miễn phí cho buổi phỏng vấn của bạn.",
    "cap.save": '<i class="fa-solid fa-bookmark"></i> Lưu Tiến Trình',
    "cap.skip": "Để sau — tiếp tục luyện tập",
    "cap.thanks": "Xong rồi — chúng tôi đã lưu tiến trình của bạn! 🙌",
    "cap.ph.name": "Tên (không bắt buộc)",
    "eg.title": "Bạn đang tiến bộ nhanh! 🔥",
    "eg.sub": "Thêm email để tiếp tục. Chúng tôi sẽ lưu tiến trình trên mọi thiết bị và gửi mẹo ôn thi miễn phí — không spam, có thể hủy bất cứ lúc nào.",
    "eg.continue": "Lưu & Tiếp Tục Luyện Tập",
    "install.title": "Thêm FutureSteps vào Màn Hình Chính",
    "install.ios": 'Nhấn nút Chia Sẻ <i class="fa-solid fa-arrow-up-from-bracket"></i> ở dưới, nhấn <strong>Thêm (More)</strong>, rồi chọn <strong>"Thêm vào MH chính"</strong>. Ứng dụng sẽ mở toàn màn hình như một app thật.',
    "install.android": "Cài đặt để luyện tập chỉ với một chạm — mở toàn màn hình và dùng được cả khi ngoại tuyến.",
    "install.manual": 'Nhấn menu <i class="fa-solid fa-ellipsis-vertical"></i> (góc trên bên phải), rồi chọn <strong>"Thêm vào MH chính"</strong>. Ứng dụng sẽ mở toàn màn hình như một app thật.',
    "install.button": "Cài Đặt",
    "gate.haveAccount": "Đã luyện tập trước đây?",
    "gate.logIn": "Tiếp tục với email của bạn",
    "gate.sendLink": "Tiếp Tục Từ Chỗ Đã Dừng",
    "gate.continue": "Tiếp Tục Luyện Tập",
    "gate.legal": "Đây chỉ là tài liệu luyện tập, không phải tư vấn pháp lý. Thông tin của bạn chỉ được chia sẻ với Future Steps Services.",
    "gate.ph.name": "Họ và tên",
    "gate.ph.email": "Email",
    "gate.ph.phone": "Số điện thoại",
    "gate.ph.restore": "Email bạn đã đăng ký",
    "gate.ph.location": "Bạn đang ở đâu? (tiểu bang hoặc Việt Nam)",
    "gate.loc.vietnam": "Việt Nam",
    "gate.loc.other": "Quốc gia khác",
    "gate.err.name": "Vui lòng nhập tên của bạn.",
    "gate.err.emailRequired": "Vui lòng nhập địa chỉ email của bạn.",
    "gate.err.email": "Địa chỉ email không hợp lệ.",
    "gate.err.phoneRequired": "Vui lòng nhập số điện thoại của bạn.",
    "gate.err.phone": "Vui lòng nhập số điện thoại hợp lệ.",
    "gate.err.location": "Vui lòng chọn nơi bạn đang ở.",
    "gate.err.save": "Có lỗi xảy ra. Vui lòng thử lại.",
    "gate.restoreNotFound": "Không tìm thấy tài khoản với email đó. Vui lòng thử lại, hoặc bắt đầu mới ở trên.",
    "gate.welcomeBack": "Chào mừng trở lại",
    "gate.loginSent": "Hãy kiểm tra email để nhận liên kết đăng nhập!",
    "gate.pendingTitle": "Kiểm Tra Email Của Bạn",
    "gate.pendingMsg": "Chúng tôi đã gửi một liên kết kích hoạt đến email bên dưới. Bạn phải nhấp vào đó để kích hoạt tài khoản trước khi có thể bắt đầu luyện tập.",
    "gate.resend": "Gửi Lại Email",
    "gate.resendSent": "Đã gửi lại email kích hoạt!",
    "gate.useDifferent": "Dùng email khác",
  }
};

const CATEGORY_LABEL_EN = {
  marriage: "Marriage-Based Green Card",
  naturalization: "Naturalization",
  asylum: "Asylum",
  f1: "F-1 Student Visa",
  b1b2: "B1/B2 Visitor Visa",
  eng_speaking: "Naturalization — English Test (Speaking)",
  eng_reading: "Naturalization — English Test (Reading)",
  eng_writing: "Naturalization — English Test (Writing)",
  flagged: "Flagged",
};

const ANSWER_LABEL_EN = {
  marriage: "Answer Tips",
  asylum: "Answer Tips",
  naturalization: "Official Answer",
  f1: "Answer Tips",
  b1b2: "Answer Tips",
  eng_speaking: "Coaching Tip",
  eng_reading: "Reading Tip",
  eng_writing: "Writing Tip",
};

const SIM_QUESTION_COUNT = 20;
const SIM_PASS_THRESHOLD = 12;
const SIM_PROGRESS_EN = "Question {current} of {total} · {correct} of {answered} correct so far";
const SIM_BADGE_SUFFIX_EN = " — Test Simulation";
const SIM_PASS_EN = "✅ PASS — You answered {correct} of {total} correctly (need at least {threshold}/20 to pass the real test)";
const SIM_FAIL_EN = "❌ NOT YET — You answered {correct} of {total} correctly (need at least {threshold}/20 to pass the real test)";
const SIM_TIMING_EN = "Total time: {total} · Average: {avg}/question";
const ACCOUNT_ERROR_EN = "Something went wrong. Please try again.";
const ACCOUNT_NO_RESULTS_EN = "No practice results yet.";
const PROGRESS_SUB_EN = "Across {rounds} practice round(s)";
const ACCOUNT_RECENT_RESULTS_EN = "Recent Results";
const ENGLISH_RESULT_EN = {
  excellent: "🌟 Excellent — {pct}% correct. You're ready for the English portion of the interview!",
  good: "👍 Good — {pct}% correct. Review a bit more before your interview.",
  needsPractice: "📚 Needs Practice — {pct}% correct. Keep practicing speaking, reading, and writing.",
};

/* Categories that use the Practice Questions / Green Flags / Red Flags /
   Documents content toggle. Green flags now apply to every main category
   (incl. naturalization); red flags/documents show per whatever is seeded. */
const OPEN_FIELD = ["marriage", "asylum", "f1", "b1b2"];
const MAIN_CATEGORIES = ["marriage", "naturalization", "asylum", "f1", "b1b2"];
const CONTENT_BADGE_SUFFIX_EN = { green_flag: " — Green Flags", red_flag: " — Red Flags", checklist: " — Documents" };
const CONTENT_ANSWER_LABEL_EN = { green_flag: "Why It Helps / How to Show It", red_flag: "Why It Matters / How to Handle", checklist: "Why It Matters" };
const CONTENT_PROGRESS_EN = { green_flag: "Green flag {current} of {total}", red_flag: "Red flag {current} of {total}", checklist: "Document {current} of {total}" };

/* ── Spoken (auto-scored) civics mode ──
   Browser speech recognition captures the spoken English answer, then we grade
   it against the official civics answer with keyword matching. No AI/backend. */
const SpeechRec = window.SpeechRecognition || window.webkitSpeechRecognition;
const SPEECH_SUPPORTED = !!SpeechRec;
const SPOKEN_EN = {
  verdictPass: "✅ Looks correct — confirm or change it below.",
  verdictFail: "❌ Doesn't match the official answer — confirm or change it below.",
  verdictManual: "This question can't be auto-checked — listen to the official answer, then score yourself.",
  error: "Didn't catch that. Listen to the answer and score yourself, or restart to try again.",
};
const TYPED_EN = {
  verdictPass: "✅ Looks correct — confirm or change it below.",
  verdictFail: "❌ Doesn't match the official answer — confirm or change it below.",
  verdictManual: "This question can't be auto-checked — read the official answer, then score yourself.",
};
// Small, conservative stopword list so matching keys on the meaningful words.
const CIVICS_STOPWORDS = new Set([
  "a","an","the","of","and","or","to","in","on","for","is","are","was","were",
  "be","that","this","it","its","as","at","by","with","from",
]);

function normalizeSpeech(s) {
  return (s || "")
    .toLowerCase()
    .replace(/['’]/g, "")          // drop apostrophes: state's -> states
    .replace(/[^a-z0-9\s]/g, " ")  // punctuation & hyphens -> space
    .replace(/\s+/g, " ")
    .trim();
}

function contentTokens(s) {
  return normalizeSpeech(s).split(" ").filter(w => w.length >= 2 && !CIVICS_STOPWORDS.has(w));
}

// Civics answers list acceptable variants separated by ";". "(parenthetical)"
// text is an optional/alternative form (e.g. "Twenty-seven (27)").
function acceptableVariants(answerEn) {
  return answerEn.split(/;|\n/).map(v => v.trim()).filter(Boolean);
}

function transcriptMatchesAnswer(transcript, answerEn) {
  const tNorm = normalizeSpeech(transcript);
  if (!tNorm) return false;
  const tWords = new Set(tNorm.split(" "));
  return acceptableVariants(answerEn).some(variant => {
    // A parenthetical is an accepted alternative (often a numeral like "(27)").
    const parenAlts = [...variant.matchAll(/\(([^)]*)\)/g)]
      .map(m => normalizeSpeech(m[1])).filter(Boolean);
    if (parenAlts.some(alt => alt.includes(" ") ? tNorm.includes(alt) : tWords.has(alt))) return true;
    // Otherwise require most of the variant's meaningful words to be present.
    const tokens = contentTokens(variant.replace(/\([^)]*\)/g, " "));
    if (!tokens.length) return false;
    const present = tokens.filter(tok => tWords.has(tok)).length;
    return present >= Math.max(1, Math.ceil(tokens.length * 0.6));
  });
}

// True if any speech-recognition hypothesis matches the official answer.
function gradeCivicsAnswer(transcripts, answerEn) {
  return transcripts.some(t => transcriptMatchesAnswer(t, answerEn));
}

// Some civics answers depend on lookups (President, your Senator, etc.) and
// can't be auto-graded — those fall back to self-scoring.
function isCivicsAutoScorable(q) {
  return !/look up|answers vary|check uscis|senate\.gov|house\.gov/i.test(q.answer_en);
}

function speakText(text) {
  if (!("speechSynthesis" in window) || !text) return;
  window.speechSynthesis.cancel();
  const utter = new SpeechSynthesisUtterance(text);
  utter.lang = "en-US";
  utter.rate = 0.95;
  window.speechSynthesis.speak(utter);
}

const DONE_MESSAGES = {
  finished: {
    en: "You've gone through every question in this round. Great work!",
    vi: "Bạn đã hoàn thành tất cả câu hỏi trong lượt này. Làm tốt lắm!",
  },
  flaggedEmpty: {
    en: "You haven't flagged any questions to review yet. Tap the star on any question to save it here.",
    vi: "Bạn chưa đánh dấu câu hỏi nào để ôn lại. Bấm vào ngôi sao trên bất kỳ câu hỏi nào để lưu lại ở đây.",
  },
  reviewEmpty: {
    en: "No missed civics questions to review right now — nice work! Any you miss on the Simulate or Spoken test will collect here.",
    vi: "Hiện không có câu Thi Dân Sự nào bị sai để ôn lại — làm tốt lắm! Những câu anh/chị trả lời sai trong bài Mô Phỏng hoặc Thi Nói sẽ được lưu ở đây.",
  },
};

const REVIEW_DONE_EN = "Review complete — you cleared {cleared} of {total}. {remaining} still to review.";
const REVIEW_BADGE_SUFFIX_EN = " — Review Missed";

const FLAG_STORAGE_KEY = "interviewPrepFlaggedIds";
const MISSED_STORAGE_KEY = "interviewPrepMissedIds";
const REGISTERED_STORAGE_KEY = "interviewPrepRegistered";

// English placeholders / messages for the registration gate (VI live in translations.vi).
const GATE_EN = {
  "gate.ph.name": "Full name",
  "gate.ph.email": "Email",
  "gate.ph.phone": "Phone number",
  "gate.ph.restore": "Email you registered with",
  "gate.ph.location": "Where are you? (state or Vietnam)",
  "gate.loc.vietnam": "Vietnam",
  "gate.loc.other": "Other country",
  "gate.err.name": "Please enter your name.",
  "gate.err.emailRequired": "Please enter your email address.",
  "gate.err.email": "Please enter a valid email address.",
  "gate.err.phoneRequired": "Please enter your phone number.",
  "gate.err.phone": "Please enter a valid phone number.",
  "gate.err.location": "Please choose where you are.",
  "gate.err.save": "Something went wrong. Please try again.",
  "gate.loginSent": "Check your email for a login link!",
  "gate.resendSent": "Activation email resent!",
  "gate.restoreNotFound": "We couldn't find an account with that email. Try again, or start fresh above.",
  "gate.welcomeBack": "Welcome back",
  "cap.ph.name": "Name (optional)",
};
function gateText(key) {
  return currentLang === "vi" ? translations.vi[key] : GATE_EN[key];
}

// Time-of-day greeting from the browser's local clock (already the user's tz).
const GREET_EN = { morning: "Good morning", afternoon: "Good afternoon", evening: "Good evening" };
const GREET_VI = { morning: "Chào buổi sáng", afternoon: "Chào buổi chiều", evening: "Chào buổi tối" };
function greeting() {
  const h = new Date().getHours();
  const slot = h < 12 ? "morning" : h < 18 ? "afternoon" : "evening";
  return (currentLang === "vi" ? GREET_VI : GREET_EN)[slot];
}

/* ── States/territories for the account dropdown (value = code stored in the
   user's profile; must match the `code` column in state_officials) ── */
const STATES = [
  { code: "AL", name: "Alabama" }, { code: "AK", name: "Alaska" },
  { code: "AZ", name: "Arizona" }, { code: "AR", name: "Arkansas" },
  { code: "CA", name: "California" }, { code: "CO", name: "Colorado" },
  { code: "CT", name: "Connecticut" }, { code: "DE", name: "Delaware" },
  { code: "FL", name: "Florida" }, { code: "GA", name: "Georgia" },
  { code: "HI", name: "Hawaii" }, { code: "ID", name: "Idaho" },
  { code: "IL", name: "Illinois" }, { code: "IN", name: "Indiana" },
  { code: "IA", name: "Iowa" }, { code: "KS", name: "Kansas" },
  { code: "KY", name: "Kentucky" }, { code: "LA", name: "Louisiana" },
  { code: "ME", name: "Maine" }, { code: "MD", name: "Maryland" },
  { code: "MA", name: "Massachusetts" }, { code: "MI", name: "Michigan" },
  { code: "MN", name: "Minnesota" }, { code: "MS", name: "Mississippi" },
  { code: "MO", name: "Missouri" }, { code: "MT", name: "Montana" },
  { code: "NE", name: "Nebraska" }, { code: "NV", name: "Nevada" },
  { code: "NH", name: "New Hampshire" }, { code: "NJ", name: "New Jersey" },
  { code: "NM", name: "New Mexico" }, { code: "NY", name: "New York" },
  { code: "NC", name: "North Carolina" }, { code: "ND", name: "North Dakota" },
  { code: "OH", name: "Ohio" }, { code: "OK", name: "Oklahoma" },
  { code: "OR", name: "Oregon" }, { code: "PA", name: "Pennsylvania" },
  { code: "RI", name: "Rhode Island" }, { code: "SC", name: "South Carolina" },
  { code: "SD", name: "South Dakota" }, { code: "TN", name: "Tennessee" },
  { code: "TX", name: "Texas" }, { code: "UT", name: "Utah" },
  { code: "VT", name: "Vermont" }, { code: "VA", name: "Virginia" },
  { code: "WA", name: "Washington" }, { code: "WV", name: "West Virginia" },
  { code: "WI", name: "Wisconsin" }, { code: "WY", name: "Wyoming" },
  { code: "DC", name: "Washington, D.C." },
  { code: "PR", name: "Puerto Rico" }, { code: "GU", name: "Guam" },
  { code: "VI", name: "U.S. Virgin Islands" }, { code: "AS", name: "American Samoa" },
  { code: "MP", name: "Northern Mariana Islands" },
];

/* The registration gate stores the full state name as user_metadata.location
   ("Texas"), while the Account panel's dropdown stores the two-letter code as
   user_metadata.state ("TX"). This maps the former to the latter so a
   customer's signup-time location also drives the localized civics answers,
   not just a separate later visit to Account settings. */
const STATE_NAME_TO_CODE = Object.fromEntries(STATES.map(s => [s.name, s.code]));

/* The three civics questions whose correct answer depends on the applicant's
   state. Matched against the (lowercased, trimmed) English question text.
   "Name your U.S. representative" is district-level, not state-level, so it is
   intentionally left as a generic pointer. */
const LOCALIZABLE_CIVICS = {
  governor: "who is the governor of your state now?",
  senator: "who is one of your state's u.s. senators now?",
  capital: "what is the capital of your state?",
};

/* Officials keyed by state code, loaded from the state_officials table. */
let stateOfficials = {};

function statePlaceholderText() {
  return currentLang === "vi" ? translations.vi["account.statePlaceholder"] : "State (optional)";
}

function populateStateSelect() {
  const sel = document.getElementById("accountStateInput");
  if (!sel) return;
  const selected = sel.value;
  sel.innerHTML = `<option value="">${statePlaceholderText()}</option>` +
    STATES.map(s => `<option value="${s.code}">${s.name}</option>`).join("");
  sel.value = selected;
}

/* ── Registration gate ──
   The front door asks only for location (needed to serve state-specific civics
   answers) — everyone starts practicing immediately. Email is captured later,
   after the user has felt some value (see the delayed email capture below).
   Logged-in users and returning visitors on this device skip the gate. */

function isRegistered() {
  return !!currentUser || localStorage.getItem(REGISTERED_STORAGE_KEY) === "1";
}

function markRegistered() {
  try { localStorage.setItem(REGISTERED_STORAGE_KEY, "1"); } catch (e) {}
}

/* ── Anonymous device identity + local/backend activity tracking ──
   Everyone who registers at the gate gets a stable client_id (kept on the
   device), used to save practice progress/activity to the backend and
   correlate it with their lead. Practicing itself requires a real account:
   the gate form sends an activation email (magic link), and only once they
   click it and get a real Supabase session are they let in. */
const CLIENT_ID_KEY = "interviewPrepClientId";
const REG_EMAIL_KEY = "interviewPrepRegEmail";
const REG_NAME_KEY  = "interviewPrepRegName";
const REG_PHONE_KEY = "interviewPrepRegPhone";
const REG_LOCATION_KEY = "interviewPrepRegLocation";
const PROFILE_STATE_KEY = "interviewPrepProfileState";
function lsGet(k) { try { return localStorage.getItem(k) || ""; } catch (e) { return ""; } }
const PENDING_EMAIL_KEY = "interviewPrepPendingActivationEmail";
const PROGRESS_KEY  = "interviewPrepProgress";
const SESSION_ID_KEY = "interviewPrepSessionId";
const FIRST_TOUCH_KEY = "interviewPrepFirstTouchLogged";

/* UTM/referrer this page loaded with — captured once and reused for every
   analytics event this pageview fires (see supabase/ANALYTICS.md). */
const urlParams = new URLSearchParams(window.location.search);
const utmParams = {
  source:   urlParams.get("utm_source")   || null,
  medium:   urlParams.get("utm_medium")   || null,
  campaign: urlParams.get("utm_campaign") || null,
  content:  urlParams.get("utm_content")  || null,
  term:     urlParams.get("utm_term")     || null,
};

/* The device/browser id shared with the website (llc-web) to stitch one
   human's journey across both properties: the website's "Practice now" CTA
   appends ?aid=<id>, and we adopt it here over any id already on this device. */
function getClientId() {
  let id = localStorage.getItem(CLIENT_ID_KEY);
  const urlAid = urlParams.get("aid");
  if (urlAid && urlAid !== id) {
    id = urlAid;
    try { localStorage.setItem(CLIENT_ID_KEY, id); } catch (e) {}
  }
  if (!id) {
    id = (window.crypto && crypto.randomUUID)
      ? crypto.randomUUID()
      : "c_" + Date.now().toString(36) + Math.random().toString(36).slice(2, 10);
    try { localStorage.setItem(CLIENT_ID_KEY, id); } catch (e) {}
  }
  return id;
}

function getSessionId() {
  let id = sessionStorage.getItem(SESSION_ID_KEY);
  if (!id) {
    id = (window.crypto && crypto.randomUUID)
      ? crypto.randomUUID()
      : "s_" + Date.now().toString(36) + Math.random().toString(36).slice(2, 10);
    try { sessionStorage.setItem(SESSION_ID_KEY, id); } catch (e) {}
  }
  return id;
}

/* Record this device's first-touch attribution, once ever. Fire-and-forget,
   and safe to call every page load — it no-ops once FIRST_TOUCH_KEY is set. */
async function logFirstTouchIfNeeded() {
  if (!supabaseClient || IS_DEV_HOST) return;
  try { if (localStorage.getItem(FIRST_TOUCH_KEY)) return; } catch (e) {}
  try {
    const { error } = await supabaseClient.from("anon_visitors").insert({
      anon_id: getClientId(),
      first_property: "app",
      first_referrer: document.referrer || null,
      first_landing_path: window.location.pathname,
      first_utm_source: utmParams.source,
      first_utm_medium: utmParams.medium,
      first_utm_campaign: utmParams.campaign,
      first_utm_content: utmParams.content,
      first_utm_term: utmParams.term,
    });
    if (error && error.code !== "23505") throw error;
    try { localStorage.setItem(FIRST_TOUCH_KEY, "1"); } catch (e) {}
  } catch (err) {
    console.error("Failed to log first touch:", err);
  }
}

/* Log one unified analytics event (see the taxonomy in supabase/ANALYTICS.md).
   Fire-and-forget: never block or break the UI on a logging failure. */
async function logEvent(eventName, props = {}) {
  if (!supabaseClient || IS_DEV_HOST) return;
  try {
    await supabaseClient.from("events").insert({
      anon_id: getClientId(),
      property: "app",
      event_name: eventName,
      session_id: getSessionId(),
      page_path: window.location.pathname,
      referrer: document.referrer || null,
      utm_source: utmParams.source,
      utm_medium: utmParams.medium,
      utm_campaign: utmParams.campaign,
      utm_content: utmParams.content,
      utm_term: utmParams.term,
      props,
    });
  } catch (err) {
    console.error("Failed to log event:", eventName, err);
  }
}

/* Upsert + link the current device to a person (register or magic-link login).
   SECURITY DEFINER RPC — see identify() in supabase/add_analytics_core.sql. */
async function identifyPerson({ name, email, phone, location, property = "app" } = {}) {
  if (!supabaseClient || IS_DEV_HOST) return;
  try {
    await supabaseClient.rpc("identify", {
      p_anon_id: getClientId(),
      p_name: name || null,
      p_email: email || null,
      p_phone: phone || null,
      p_location: location || null,
      p_property: property,
    });
  } catch (err) {
    console.error("Failed to identify person:", err);
  }
}

function registeredEmail() {
  return (currentUser && currentUser.email) || localStorage.getItem(REG_EMAIL_KEY) || null;
}

function loadLocalProgress() {
  const empty = { correct: 0, total: 0, rounds: 0, reviewed: 0, cats: {} };
  try {
    const p = Object.assign(empty, JSON.parse(localStorage.getItem(PROGRESS_KEY)) || {});
    if (!p.cats || typeof p.cats !== "object") p.cats = {};   // tolerate pre-cats saves
    return p;
  } catch (e) { return empty; }
}

// Scored rounds only: add correct/total, which drive the accuracy stat. The
// round + reviewed counts are recorded for EVERY round in recordRoundProgress().
function addLocalProgress(correct, total) {
  const p = loadLocalProgress();
  p.correct += correct; p.total += total;
  try { localStorage.setItem(PROGRESS_KEY, JSON.stringify(p)); } catch (e) {}
}

// Every completed round counts toward the home Progress card — scored tests and
// plain flashcard practice alike: one round, plus the questions it contained,
// tallied both overall and per category (for the category chips).
function recordRoundProgress(category, reviewed) {
  const p = loadLocalProgress();
  const n = reviewed || 0;
  p.rounds += 1;
  p.reviewed += n;
  if (category) {
    const c = p.cats[category] || { rounds: 0, reviewed: 0 };
    c.rounds += 1;
    c.reviewed += n;
    p.cats[category] = c;
  }
  try { localStorage.setItem(PROGRESS_KEY, JSON.stringify(p)); } catch (e) {}
}

// Pull this device's cross-device practice totals (rounds / reviewed / accuracy /
// per-category) from the backend and adopt them when they're ahead of what's on
// this device — e.g. right after "Continue with your email" restores a user on a
// new phone. Keyed by client_id, which restore makes the same across devices.
async function syncProgressAcrossDevices() {
  if (!supabaseClient || !isRegistered()) return;
  try {
    const { data, error } = await supabaseClient.rpc("get_my_summary", { p_client_id: getClientId() });
    if (error) throw error;
    const s = (data && data[0]) || null;
    if (!s) return;
    // Deploy-order safe: the by_category field only exists once the SQL migration
    // (add_crossdevice_progress.sql) has run. Until then, don't touch local totals.
    if (typeof s.by_category === "undefined") { renderProgress(); return; }
    const serverRounds = Number(s.practice_rounds || 0);
    const local = loadLocalProgress();
    // Only adopt when the server is ahead, so we never clobber fresher local work.
    if (serverRounds > (local.rounds || 0)) {
      local.rounds = serverRounds;
      local.reviewed = Number(s.questions_reviewed || 0);
      local.total = Number(s.questions_done || 0);
      local.correct = Number(s.questions_right || 0);
      const byCat = s.by_category || {};
      local.cats = {};
      Object.keys(byCat).forEach(k => {
        local.cats[k] = {
          rounds: Number((byCat[k] && byCat[k].rounds) || 0),
          reviewed: Number((byCat[k] && byCat[k].reviewed) || 0),
        };
      });
      try { localStorage.setItem(PROGRESS_KEY, JSON.stringify(local)); } catch (e) {}
    }
    renderProgress();
  } catch (err) {
    console.error("Cross-device progress sync failed:", err);
  }
}

/* Log a practice/view event to the backend, keyed to the device + lead.
   Fire-and-forget: never block or break the UI on a logging failure. */
async function logActivity(activityType, category, data = {}) {
  if (!supabaseClient || IS_DEV_HOST) return;
  try {
    await supabaseClient.from("practice_activity").insert({
      client_id: getClientId(),
      email: registeredEmail(),
      activity_type: activityType,       // 'view' | 'practice'
      category: category || null,
      mode: data.mode || null,
      content_type: data.content_type || null,
      correct: (data.correct ?? null),
      total: (data.total ?? null),
      reviewed: (data.reviewed ?? null), // questions seen this round (cross-device counts)
    });
  } catch (err) {
    console.error("Failed to log practice activity:", err);
  }
  // Mirror into the unified events table (see supabase/ANALYTICS.md taxonomy).
  logEvent(activityType === "practice" ? "practice_complete" : "view",
    activityType === "practice"
      ? { category: category || null, mode: data.mode || null,
          content_type: data.content_type || null,
          correct: data.correct ?? null, total: data.total ?? null }
      : { category: category || null, content_type: data.content_type || null });
}

// Fill a location <select> (US states + Vietnam + Other). Used by the
// Naturalization-only location gate. value = canonical English label (CRM-stored).
function populateLocationSelect(id) {
  const sel = document.getElementById(id);
  if (!sel) return;
  const selected = sel.value;
  sel.innerHTML =
    `<option value="" disabled selected>${gateText("gate.ph.location")}</option>` +
    STATES.map(s => `<option value="${s.name}">${s.name}</option>`).join("") +
    `<option value="Vietnam">${gateText("gate.loc.vietnam")}</option>` +
    `<option value="Other country">${gateText("gate.loc.other")}</option>`;
  sel.value = selected;
}
function populateGateLocation() { populateLocationSelect("natLocation"); }

function renderGateLang() {
  const g = document.getElementById("regGate");
  if (!g) return;
  document.getElementById("gateName").placeholder = gateText("gate.ph.name");
  document.getElementById("gateEmail").placeholder = gateText("gate.ph.email");
  document.getElementById("gatePhone").placeholder = gateText("gate.ph.phone");
  document.getElementById("gateLoginEmail").placeholder = gateText("gate.ph.restore");
  document.getElementById("gateLangFlag").textContent = currentLang === "vi" ? "🇺🇸" : "🇻🇳";
  document.getElementById("gateLangLabel").textContent = currentLang === "vi" ? "English" : "Tiếng Việt";
  populateGateLocation();
}

function openGate() {
  document.getElementById("regGate").hidden = false;
  document.body.classList.add("gate-open");
}

function closeGate() {
  document.getElementById("regGate").hidden = true;
  document.body.classList.remove("gate-open");
}

// Reset the gate to its default registration form (used when (re)opening it).
function resetGateToForm() {
  const show = (id, on) => { const el = document.getElementById(id); if (el) el.hidden = !on; };
  show("gateForm", true);
  show("gateLoginPrompt", true);
  show("gateLoginBox", false);
  show("gateWelcome", false);
  show("gateMainTitle", true);
  show("gateMainSub", true);
  const legal = document.querySelector("#regGate .gate__legal");
  if (legal) legal.hidden = false;
}

function showGateIfNeeded() {
  if (isRegistered()) { closeGate(); return; }
  resetGateToForm();
  openGate();
}

function isValidEmail(v) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v);
}

// Lenient phone check: accept US and Vietnamese formats (and international) by
// counting digits only — 8 to 15 digits (E.164 max). Avoids rejecting real
// numbers with a too-strict pattern.
function isValidPhone(v) {
  const d = (v || "").replace(/\D/g, "");
  return d.length >= 8 && d.length <= 15;
}

// Close the gate and drop the user into the app immediately (front door).
function enterAppAfterGate() {
  try { localStorage.removeItem(PENDING_EMAIL_KEY); } catch (e) {}
  closeGate();
  renderAccountUI();   // show their name at the profile icon right away
  showHome();
  maybeShowNewsPopup();   // surface any unseen big news now that they're in
}

// ── Location gate (Naturalization only) ──
// Naturalization is the one category whose civics answers are state-specific, so
// we ask for the state the first time it's opened. Other categories skip this.
function hasLocation() {
  return !!lsGet(REG_LOCATION_KEY);
}
function openLocationGate() {
  const err = document.getElementById("locationError");
  if (err) err.hidden = true;
  populateLocationSelect("natLocation");
  document.getElementById("locationGate").hidden = false;
  document.body.classList.add("gate-open");
}
function closeLocationGate() {
  document.getElementById("locationGate").hidden = true;
  document.body.classList.remove("gate-open");
}
function submitNatLocation(e) {
  if (e) e.preventDefault();
  const err = document.getElementById("locationError");
  const location = document.getElementById("natLocation").value;
  if (err) err.hidden = true;
  if (!location) {
    if (err) { err.textContent = gateText("gate.err.location"); err.hidden = false; }
    return;
  }
  try {
    localStorage.setItem(REG_LOCATION_KEY, location);
    // A US state also sets the civics-localization state code right away.
    const code = STATE_NAME_TO_CODE[location];
    if (code) localStorage.setItem(PROFILE_STATE_KEY, code);
  } catch (e2) {}
  identifyPerson({ location });
  logEvent("location_set", { location });
  renderAccountUI();
  closeLocationGate();
  enterService("naturalization");   // now that we have a state, go in
}

// Front door: location only. It's the one thing the app genuinely needs up
// front (to serve state-specific civics answers), so it reads as practice setup,
// not a contact form. Name/email/phone are captured later, after the user has
// felt some value (see the post-round email capture). No lead row is written
// here — anonymous trials live in analytics (identify/events) until we have an
// email, keeping the `leads` table = real, warm leads for the morning emails.
async function submitRegistration(e) {
  if (e) e.preventDefault();
  const btn = document.getElementById("gateSubmit");
  // The front door no longer asks for location — most categories don't need it.
  // (Naturalization asks for the state only when it's actually chosen.) So this
  // is just a one-tap "start": mark the device registered and drop them in.
  btn.disabled = true;
  identifyPerson({});                 // anonymous person row (device id only)
  logEvent("setup_complete", {});
  markRegistered();
  pushAllProgressUp();                // back up any progress already on this device
  syncProgressAcrossDevices();        // pull cross-device rounds/counts if any
  btn.disabled = false;
  enterAppAfterGate();
}

// "Welcome back": a returning customer types the email OR phone they used
// before. We confirm a matching lead (find_lead_by_contact, SECURITY DEFINER),
// adopt their name + device client_id for continuity, and let them straight in.
async function restoreFromContact() {
  const val = document.getElementById("gateLoginEmail").value.trim();
  const msg = document.getElementById("gateLoginMsg");
  const btn = document.getElementById("gateLoginSend");
  msg.hidden = true;
  if (!val || !supabaseClient) return;
  btn.disabled = true;
  try {
    const { data, error } = await supabaseClient.rpc("find_lead_by_contact", { p_contact: val });
    if (error) throw error;
    const lead = data && data[0];
    if (!lead) {
      msg.textContent = gateText("gate.restoreNotFound");
      msg.className = "gate__msg gate__msg--error";
      msg.hidden = false;
      btn.disabled = false;
      return;
    }
    try {
      if (lead.client_id) localStorage.setItem(CLIENT_ID_KEY, lead.client_id);
      if (lead.name) localStorage.setItem(REG_NAME_KEY, lead.name);
      if (val.includes("@")) localStorage.setItem(REG_EMAIL_KEY, val);
      else localStorage.setItem(REG_PHONE_KEY, val);
    } catch (e) {}
    markRegistered();
    await pullProgressForContact(val);   // restore flagged + missed across devices
    btn.disabled = false;
    await showWelcomeBack(lead.name, lead.client_id || getClientId());
  } catch (err) {
    console.error("Restore failed:", err);
    msg.textContent = gateText("gate.err.save");
    msg.className = "gate__msg gate__msg--error";
    msg.hidden = false;
    btn.disabled = false;
  }
}

// Category label for the welcome recap (bilingual).
function catLabelFor(cat) {
  if (!cat) return "";
  return currentLang === "vi"
    ? (translations.vi["badge." + cat] || translations.vi["cat." + cat] || cat)
    : (CATEGORY_LABEL_EN[cat] || cat);
}

// Returning-user "Welcome back" screen: greeting + a recap of their practice,
// then a Continue button. Recap is fetched cross-device via get_my_summary().
async function showWelcomeBack(name, clientId) {
  let s = {};
  try {
    const { data } = await supabaseClient.rpc("get_my_summary", { p_client_id: clientId });
    s = (data && data[0]) || {};
  } catch (e) { console.error("Summary fetch failed:", e); }

  document.getElementById("gateForm").hidden = true;
  document.getElementById("gateLoginPrompt").hidden = true;
  document.getElementById("gateLoginBox").hidden = true;
  ["gateMainTitle", "gateMainSub"].forEach(id => { const el = document.getElementById(id); if (el) el.hidden = true; });
  const legal = document.querySelector("#regGate .gate__legal");
  if (legal) legal.hidden = true;

  document.getElementById("gateWelcomeGreeting").textContent = greeting() + " 👋";
  document.getElementById("gateWelcomeName").textContent =
    (currentLang === "vi" ? "Chào mừng trở lại, " : "Welcome back, ") + (name || "");
  renderWelcomeStats(s);
  document.getElementById("gateWelcome").hidden = false;
}

function renderWelcomeStats(s) {
  const el = document.getElementById("gateWelcomeStats");
  const rounds = Number(s.practice_rounds || 0);
  if (!rounds) {
    el.innerHTML = `<p class="gate__welcome-empty">${currentLang === "vi"
      ? "Sẵn sàng để luyện tập tiếp chưa?" : "Ready to jump back in?"}</p>`;
    return;
  }
  const done = Number(s.questions_done || 0), right = Number(s.questions_right || 0);
  const acc = done ? Math.round((100 * right) / done) : null;
  const cells = [
    [rounds, currentLang === "vi" ? "lượt luyện" : "rounds"],
    [Number(s.categories || 0), currentLang === "vi" ? "chủ đề" : "categories"],
  ];
  if (acc != null) cells.push([acc + "%", currentLang === "vi" ? "chính xác" : "accuracy"]);
  let html = `<div class="gate__welcome-grid">` + cells.map(([n, l]) =>
    `<div class="gate__welcome-stat"><span class="gate__welcome-num">${n}</span><span class="gate__welcome-lbl">${l}</span></div>`).join("") + `</div>`;
  if (s.top_category)
    html += `<p class="gate__welcome-note">${currentLang === "vi" ? "Chủ đề luyện nhiều nhất" : "Your top category"}: <strong>${catLabelFor(s.top_category)}</strong></p>`;
  if (s.last_active) {
    const d = new Date(s.last_active).toLocaleDateString(currentLang === "vi" ? "vi-VN" : "en-US", { month: "short", day: "numeric" });
    html += `<p class="gate__welcome-note">${currentLang === "vi" ? "Hoạt động gần nhất" : "Last active"}: ${d}</p>`;
  }
  el.innerHTML = html;
}

// New/returning user greeting on the home screen (non-blocking, no extra step).
function renderHomeGreeting() {
  const el = document.getElementById("homeGreeting");
  if (!el) return;
  const name = lsGet(REG_NAME_KEY);
  if (isRegistered() && name) {
    el.textContent = `${greeting()}, ${name} 👋`;
    el.hidden = false;
  } else {
    el.hidden = true;
  }
}

/* ── Latest immigration news (home section) ──
   Bilingual stories from the `news` table (see supabase/add_news.sql), kept in
   sync with the website's news section by a weekly scheduled task. Cards are
   collapsed to a few lines; tapping one expands it. */
let newsItems = [];

async function loadNews() {
  if (!supabaseClient) return;
  try {
    const { data, error } = await supabaseClient.from("news").select("*").order("slot");
    if (error) throw error;
    newsItems = data || [];
    renderNews();
    maybeShowNewsPopup();
  } catch (err) {
    console.error("Failed to load news:", err); // e.g. table not migrated yet — section just stays hidden
  }
}

const NEWS_TAG_ICON = { alert: "fa-triangle-exclamation", warning: "fa-scale-balanced", info: "fa-circle-info" };
const NEWS_SEEN_KEY = "interviewPrepNewsSeen";
let currentNewsItem = null;

function newsType(n) {
  return ["alert", "warning", "info"].includes(n.tag_type) ? n.tag_type : "info";
}
function newsFaqs(n) {
  return Array.isArray(n.faqs) ? n.faqs : [];
}
function featuredNews() {
  return newsItems.find(n => n.is_featured) || null;
}
function newsDateLabel(n) {
  return n.news_date
    ? new Date(n.news_date + "T12:00:00").toLocaleDateString(currentLang === "vi" ? "vi-VN" : "en-US", { month: "short", day: "numeric", year: "numeric" })
    : "";
}

function renderNews() {
  renderBreakingBanner();
  const sec = document.getElementById("newsSection");
  const list = document.getElementById("newsCards");
  if (!sec || !list) return;
  if (!newsItems.length) { sec.hidden = true; return; }
  const vi = currentLang === "vi";
  list.innerHTML = newsItems.map(n => {
    const type = newsType(n);
    const src = n.source_url
      ? `<a href="${escapeHtml(n.source_url)}" target="_blank" rel="noopener">${escapeHtml(n.source_name || "Source")} <i class="fa-solid fa-arrow-up-right-from-square"></i></a>`
      : "";
    const nFaq = newsFaqs(n).length;
    const faqPill = nFaq
      ? `<span class="news-card__faq-pill"><i class="fa-solid fa-comments"></i> ${nFaq} ${vi ? translations.vi["news.practiceHint"] : "practice questions"}</span>`
      : "";
    const ribbon = n.is_featured
      ? `<span class="news-card__ribbon"><i class="fa-solid fa-bolt"></i> ${vi ? translations.vi["news.breaking"] : "Breaking"}</span>`
      : "";
    return `<article class="news-card news-card--${type}${n.is_featured ? " news-card--featured" : ""}" data-slot="${n.slot}" tabindex="0" role="button">
      ${ribbon}
      <span class="news-card__tag"><i class="fa-solid ${NEWS_TAG_ICON[type]}"></i> ${escapeHtml(vi ? n.tag_vi : n.tag_en)}</span>
      <h4 class="news-card__title">${escapeHtml(vi ? n.title_vi : n.title_en)}</h4>
      <p class="news-card__desc">${escapeHtml(vi ? n.desc_vi : n.desc_en)}</p>
      ${faqPill}
      <div class="news-card__meta"><span><i class="fa-regular fa-calendar"></i> ${newsDateLabel(n)}</span>${src}</div>
    </article>`;
  }).join("");
  sec.hidden = false;
}

// The featured story gets a highlighted banner at the top of home.
function renderBreakingBanner() {
  const banner = document.getElementById("breakingBanner");
  if (!banner) return;
  const f = featuredNews();
  if (!f || appView !== "home") { banner.hidden = true; return; }
  document.getElementById("breakingBannerTitle").textContent = currentLang === "vi" ? f.title_vi : f.title_en;
  banner.hidden = false;
}

// News detail modal: full story, source, and the practice Q&A accordion.
function openNewsModal(n) {
  if (!n) return;
  currentNewsItem = n;
  const vi = currentLang === "vi";
  const type = newsType(n);
  const tagEl = document.getElementById("newsModalTag");
  tagEl.className = `news-modal__tag news-modal__tag--${type}`;
  tagEl.innerHTML = `<i class="fa-solid ${NEWS_TAG_ICON[type]}"></i> ${escapeHtml(vi ? n.tag_vi : n.tag_en)}`;
  document.getElementById("newsModalTitle").textContent = vi ? n.title_vi : n.title_en;
  const src = n.source_url
    ? ` · <a href="${escapeHtml(n.source_url)}" target="_blank" rel="noopener">${escapeHtml(n.source_name || "Source")} <i class="fa-solid fa-arrow-up-right-from-square"></i></a>`
    : "";
  document.getElementById("newsModalMeta").innerHTML = `<i class="fa-regular fa-calendar"></i> ${newsDateLabel(n)}${src}`;
  document.getElementById("newsModalDesc").textContent = vi ? n.desc_vi : n.desc_en;

  const faqWrap = document.getElementById("newsModalFaq");
  const faqList = document.getElementById("newsModalFaqList");
  const faqs = newsFaqs(n);
  if (faqs.length) {
    faqList.innerHTML = faqs.map((f, i) => `
      <div class="news-faq" data-i="${i}">
        <button class="news-faq__q" type="button">
          <span>${escapeHtml(vi ? f.q_vi : f.q_en)}</span>
          <i class="fa-solid fa-chevron-down"></i>
        </button>
        <div class="news-faq__a">${escapeHtml(vi ? f.a_vi : f.a_en)}</div>
      </div>`).join("");
    faqWrap.hidden = false;
  } else {
    faqWrap.hidden = true;
  }

  document.getElementById("newsModal").hidden = false;
  document.body.classList.add("gate-open");
  document.querySelector(".news-modal__card").scrollTop = 0;
}

function closeNewsModal() {
  document.getElementById("newsModal").hidden = true;
  document.body.classList.remove("gate-open");
  currentNewsItem = null;
}

// Auto-pop the featured story once per version (keyed by slot + date), so a big
// change surfaces itself. Self-guarded, so it is safe to call more than once.
function maybeShowNewsPopup() {
  if (!isRegistered() || document.body.classList.contains("gate-open")) return;
  const f = featuredNews();
  if (!f) return;
  const key = "s" + f.slot + ":" + (f.news_date || f.updated_at || "");
  let seen = "";
  try { seen = localStorage.getItem(NEWS_SEEN_KEY) || ""; } catch (e) {}
  if (seen === key) return;
  try { localStorage.setItem(NEWS_SEEN_KEY, key); } catch (e) {}
  openNewsModal(f);
  logEvent("news_popup_shown", { slot: f.slot });
}

/* ── Interview-date countdown ──
   The user tells us their interview date once; home then shows a countdown plus
   a daily pacing nudge (civics-specific when they practice naturalization).
   Date lives on the device; setting it also logs an event for the CRM. */
const INTERVIEW_DATE_KEY = "interviewPrepInterviewDate";
const CD_SNOOZE_KEY = "interviewPrepCountdownSnooze";
const CIVICS_QUESTION_COUNT = 128;

const CD_EN = {
  days: "{n} days until your interview",
  tomorrow: "Your interview is tomorrow!",
  today: "Your interview is today — good luck! 🍀",
  past: "Hope your interview went well! 🎉",
  nudgeCivics: "Study about {n} civics questions a day to cover all 128 before your interview.",
  nudgeCivicsEasy: "You have plenty of time — a few civics questions a day covers all 128.",
  nudgeGeneric: "A little practice every day builds real confidence — aim for one round a day.",
};
const CD_VI = {
  days: "Còn {n} ngày đến buổi phỏng vấn của bạn",
  tomorrow: "Buổi phỏng vấn của bạn là ngày mai!",
  today: "Buổi phỏng vấn của bạn là hôm nay — chúc may mắn! 🍀",
  past: "Hy vọng buổi phỏng vấn của bạn diễn ra tốt đẹp! 🎉",
  nudgeCivics: "Học khoảng {n} câu dân sự mỗi ngày để ôn hết 128 câu trước buổi phỏng vấn.",
  nudgeCivicsEasy: "Bạn còn nhiều thời gian — chỉ cần vài câu dân sự mỗi ngày là ôn hết 128 câu.",
  nudgeGeneric: "Luyện tập một chút mỗi ngày sẽ tạo nên sự tự tin thật sự — hãy đặt mục tiêu một lượt mỗi ngày.",
};

// Local (not UTC) YYYY-MM-DD, optionally offset by whole days.
function localDateStamp(offsetDays = 0) {
  const d = new Date();
  d.setDate(d.getDate() + offsetDays);
  return d.getFullYear() + "-" + String(d.getMonth() + 1).padStart(2, "0") + "-" + String(d.getDate()).padStart(2, "0");
}

function daysUntilInterview() {
  const dateStr = lsGet(INTERVIEW_DATE_KEY);
  if (!dateStr) return null;
  const today = new Date(); today.setHours(0, 0, 0, 0);
  return Math.round((new Date(dateStr + "T00:00:00") - today) / 86400000);
}

function renderCountdown() {
  const card = document.getElementById("countdownCard");
  if (!card) return;
  const setEl = document.getElementById("countdownSet");
  const showEl = document.getElementById("countdownShow");
  if (!isRegistered() || appView !== "home") { card.hidden = true; return; }
  const dateStr = lsGet(INTERVIEW_DATE_KEY);

  if (!dateStr) {
    // No date yet: a small "when is your interview?" prompt, snoozable for a week.
    const snoozedUntil = lsGet(CD_SNOOZE_KEY);
    card.hidden = !!snoozedUntil && localDateStamp(0) < snoozedUntil;
    setEl.hidden = false;
    showEl.hidden = true;
    const input = document.getElementById("interviewDateInput");
    input.min = localDateStamp(0);
    return;
  }

  card.hidden = false;
  setEl.hidden = true;
  showEl.hidden = false;
  const t = currentLang === "vi" ? CD_VI : CD_EN;
  const days = daysUntilInterview();
  let msg;
  if (days > 1) msg = "📅 " + t.days.replace("{n}", days);
  else if (days === 1) msg = "📅 " + t.tomorrow;
  else if (days === 0) msg = t.today;
  else msg = t.past;
  document.getElementById("countdownDays").textContent = msg;

  // Pacing nudge: civics math for naturalization practicers, encouragement otherwise.
  let nudge = "";
  if (days > 0) {
    const p = loadLocalProgress();
    const natFocus = p.cats && p.cats.naturalization && p.cats.naturalization.rounds > 0;
    if (natFocus) {
      const perDay = Math.ceil(CIVICS_QUESTION_COUNT / days);
      nudge = perDay <= 2 ? t.nudgeCivicsEasy : t.nudgeCivics.replace("{n}", perDay);
    } else {
      nudge = t.nudgeGeneric;
    }
  }
  const nudgeEl = document.getElementById("countdownNudge");
  nudgeEl.textContent = nudge;
  nudgeEl.hidden = !nudge;
}

function saveInterviewDate() {
  const v = document.getElementById("interviewDateInput").value;
  if (!v) return;
  try {
    localStorage.setItem(INTERVIEW_DATE_KEY, v);
    localStorage.removeItem(CD_SNOOZE_KEY);
  } catch (e) {}
  logEvent("interview_date_set", { date: v, days_left: daysUntilInterview() });
  renderCountdown();
}

function editInterviewDate() {
  const input = document.getElementById("interviewDateInput");
  input.value = lsGet(INTERVIEW_DATE_KEY);
  input.min = localDateStamp(0);
  document.getElementById("countdownShow").hidden = true;
  document.getElementById("countdownSet").hidden = false;
}

function clearInterviewDate() {
  try { localStorage.removeItem(INTERVIEW_DATE_KEY); } catch (e) {}
  logEvent("interview_date_cleared", {});
  renderCountdown();
}

function snoozeCountdown() {
  try { localStorage.setItem(CD_SNOOZE_KEY, localDateStamp(7)); } catch (e) {}
  renderCountdown();
}

// ── In-app feedback (ease + helpfulness), shown after a completed round ──
const FEEDBACK_DONE_KEY = "interviewPrepFeedbackGiven";
let fbEase = 0, fbHelpful = 0, fbRecommend = 0;

function hasGivenFeedback() {
  try { return localStorage.getItem(FEEDBACK_DONE_KEY) === "1"; } catch (e) { return false; }
}

// Called when a practice round finishes. Auto-opens once; afterwards leaves a
// small re-open link. Never blocks — the done screen's other buttons stay live.
function maybeShowFeedback() {
  const card = document.getElementById("feedbackCard");
  const reopen = document.getElementById("feedbackReopen");
  if (!card || !reopen) return;
  if (hasGivenFeedback()) { card.hidden = true; reopen.hidden = false; }
  else openFeedback();
}

function openFeedback() {
  const card = document.getElementById("feedbackCard");
  if (!card) return;
  document.getElementById("feedbackReopen").hidden = true;
  card.hidden = false;
  document.getElementById("feedbackForm").hidden = false;
  document.getElementById("feedbackThanks").hidden = true;
  fbEase = 0; fbHelpful = 0; fbRecommend = 0;
  card.querySelectorAll(".fb-scale button").forEach(b => b.classList.remove("on"));
  const comment = document.getElementById("feedbackComment");
  if (comment) {
    comment.value = "";
    // Placeholder isn't a data-i18n innerHTML node, so translate it here on open.
    comment.placeholder = currentLang === "vi"
      ? translations.vi["fb.commentPh"]
      : "Anything you'd like us to know…";
  }
  document.getElementById("feedbackSend").disabled = true;
  // Make sure it's actually visible — the card sits above the email-capture card,
  // so on a phone it can open off-screen unless we bring it into view.
  requestAnimationFrame(() => card.scrollIntoView({ behavior: "smooth", block: "center" }));
}

// ease + helpful are required (they gate Send); recommend is optional.
function selectFbScale(row, val, btn) {
  if (row === "ease") fbEase = val;
  else if (row === "recommend") fbRecommend = val;
  else fbHelpful = val;
  btn.parentElement.querySelectorAll("button").forEach(b => b.classList.toggle("on", b === btn));
  document.getElementById("feedbackSend").disabled = !(fbEase && fbHelpful);
}

async function submitFeedback() {
  if (!fbEase || !fbHelpful) return;
  try {
    const comment = (document.getElementById("feedbackComment")?.value || "").trim() || null;
    if (supabaseClient) {
      await supabaseClient.from("feedback").insert({
        client_id: getClientId(),
        email: registeredEmail(),
        phone: (localStorage.getItem(REG_PHONE_KEY) || null),
        ease: fbEase, helpful: fbHelpful,
        recommend: fbRecommend || null,
        comment,
      });
    }
    logEvent("feedback_submitted", { ease: fbEase, helpful: fbHelpful, recommend: fbRecommend || null });
  } catch (err) { console.error("Feedback failed:", err); }
  try { localStorage.setItem(FEEDBACK_DONE_KEY, "1"); } catch (e) {}
  document.getElementById("feedbackForm").hidden = true;
  document.getElementById("feedbackThanks").hidden = false;
  document.getElementById("feedbackReopen").hidden = true;
}

function skipFeedback() {
  try { localStorage.setItem(FEEDBACK_DONE_KEY, "1"); } catch (e) {}
  document.getElementById("feedbackCard").hidden = true;
  document.getElementById("feedbackReopen").hidden = false;
}

/* ── Delayed email capture ──
   The front door only asks for location. We ask for an email AFTER the user has
   felt some value: a dismissible nudge on the done screen after each round, then
   a hard (blocking) gate before the 3rd round. This is where a `leads` row is
   actually created — so every lead is someone who has practiced, i.e. warm. */
const ROUND_COUNT_KEY = "interviewPrepRoundCount";
const EMAIL_GATE_AT_ROUND = 3;   // 3rd round requires an email before it starts
let pendingAfterEmail = null;    // action to resume once the hard gate is cleared

function hasEmailLead() {
  return !!(currentUser && currentUser.email) || !!lsGet(REG_EMAIL_KEY);
}

function roundCount() {
  try { return parseInt(localStorage.getItem(ROUND_COUNT_KEY) || "0", 10) || 0; }
  catch (e) { return 0; }
}

function bumpRoundCount() {
  const n = roundCount() + 1;
  try { localStorage.setItem(ROUND_COUNT_KEY, String(n)); } catch (e) {}
  return n;
}

/* Called at every round completion (replaces the bare maybeShowFeedback call).
   Primary card, one per done screen: users who owe us an email see the capture
   card; everyone else sees the usual feedback card. Feedback is never fully
   hidden though — in the pre-email phase we still expose the small "Rate the
   app" link so a user can leave feedback whenever they want. */
function onRoundComplete(scored = {}) {
  bumpRoundCount();
  const reviewed = quizSet.length;
  recordRoundProgress(currentCategory, reviewed);   // count this round locally
  // Log EVERY round to the backend (not just scored tests) so rounds + review
  // counts follow the user across devices via get_my_summary(). `correct`/`total`
  // stay null for un-scored practice so they don't dilute the accuracy stat.
  logActivity("practice", currentCategory, {
    reviewed,
    mode: scored.mode || (simMode ? "simulate" : reviewMode ? "review" : mockMode ? "mock" : "practice"),
    content_type: scored.content_type || contentType,
    correct: (scored.correct ?? null),
    total: (scored.total ?? null),
  });
  if (!hasEmailLead()) {
    document.getElementById("feedbackCard").hidden = true;
    maybeShowEmailCapture();
    // Keep feedback reachable via the reopen link (unless already given).
    const reopen = document.getElementById("feedbackReopen");
    if (reopen) reopen.hidden = hasGivenFeedback();
  } else {
    document.getElementById("emailCapture").hidden = true;
    maybeShowFeedback();
  }
}

/* Persist an email lead. Writes the `leads` row (the first time we have a real
   email for this device), links the person, and backs up on-device progress. */
async function captureEmailLead(email, name) {
  try {
    localStorage.setItem(REG_EMAIL_KEY, email);
    if (name) localStorage.setItem(REG_NAME_KEY, name);
  } catch (e) {}
  const location = lsGet(REG_LOCATION_KEY) || null;
  const phone = lsGet(REG_PHONE_KEY) || null;
  try {
    if (supabaseClient) {
      const { error } = await supabaseClient.from("leads")
        .insert({ name: name || null, email, phone, location, client_id: getClientId() });
      if (error) throw error;
    }
  } catch (err) {
    // Fail open — never trap someone behind a transient DB error.
    console.error("Failed to save email lead:", err);
  }
  identifyPerson({ name: name || null, email, phone, location });
  logEvent("email_captured");
  pushAllProgressUp();
  // Cross-device: pull any flagged/missed questions this person saved on another
  // device, so "we'll save where you left off" is actually true.
  await pullProgressForContact(email);
  renderAccountUI();
  renderHomeGreeting();
}

// ── Soft nudge: inline card on the done screen (skippable) ──
function maybeShowEmailCapture() {
  const card = document.getElementById("emailCapture");
  if (!card) return;
  document.getElementById("emailCaptureForm").hidden = false;
  document.getElementById("captureThanks").hidden = true;
  document.getElementById("captureEmail").value = lsGet(REG_EMAIL_KEY);
  document.getElementById("captureName").value = lsGet(REG_NAME_KEY);
  document.getElementById("captureEmail").placeholder = gateText("gate.ph.email");
  document.getElementById("captureName").placeholder = gateText("cap.ph.name");
  document.getElementById("captureError").hidden = true;
  card.hidden = false;
  logEvent("email_capture_shown", { round: roundCount() });
}

async function submitEmailCapture() {
  const email = document.getElementById("captureEmail").value.trim();
  const name = document.getElementById("captureName").value.trim();
  const errEl = document.getElementById("captureError");
  errEl.hidden = true;
  if (!isValidEmail(email)) { errEl.textContent = gateText("gate.err.email"); errEl.hidden = false; return; }
  const btn = document.getElementById("captureSubmit");
  btn.disabled = true;
  await captureEmailLead(email, name);
  btn.disabled = false;
  document.getElementById("emailCaptureForm").hidden = true;
  // They just gave us their email — surface the rating card right away so they
  // don't have to hunt for the "Rate the app" link. Swap the email card out for
  // it (and scroll it into view) so the prompt is unmissable on a phone.
  if (!hasGivenFeedback()) {
    document.getElementById("emailCapture").hidden = true;
    openFeedback();
  } else {
    document.getElementById("captureThanks").hidden = false;
  }
}

function skipEmailCapture() {
  document.getElementById("emailCapture").hidden = true;
}

// ── Hard gate: blocking overlay before the 3rd round (no skip) ──
/* Returns true (and opens the blocking gate) when the user owes us an email
   before starting another round; `resume` is replayed once they give it. */
function emailGateBlocks(resume) {
  if (hasEmailLead()) return false;
  if (roundCount() < EMAIL_GATE_AT_ROUND - 1) return false;
  pendingAfterEmail = resume || null;
  openEmailGate();
  return true;
}

function openEmailGate() {
  document.getElementById("emailGateEmail").value = lsGet(REG_EMAIL_KEY);
  document.getElementById("emailGateName").value = lsGet(REG_NAME_KEY);
  document.getElementById("emailGateEmail").placeholder = gateText("gate.ph.email");
  document.getElementById("emailGateName").placeholder = gateText("cap.ph.name");
  document.getElementById("emailGateLangFlag").textContent = currentLang === "vi" ? "🇺🇸" : "🇻🇳";
  document.getElementById("emailGateLangLabel").textContent = currentLang === "vi" ? "English" : "Tiếng Việt";
  document.getElementById("emailGateError").hidden = true;
  document.getElementById("emailGate").hidden = false;
  document.body.classList.add("gate-open");
  logEvent("email_gate_shown", { round: roundCount() });
}

function closeEmailGate() {
  document.getElementById("emailGate").hidden = true;
  document.body.classList.remove("gate-open");
}

async function submitEmailGate(e) {
  if (e) e.preventDefault();
  const email = document.getElementById("emailGateEmail").value.trim();
  const name = document.getElementById("emailGateName").value.trim();
  const errEl = document.getElementById("emailGateError");
  errEl.hidden = true;
  if (!isValidEmail(email)) { errEl.textContent = gateText("gate.err.email"); errEl.hidden = false; return; }
  const btn = document.getElementById("emailGateSubmit");
  btn.disabled = true;
  await captureEmailLead(email, name);
  btn.disabled = false;
  closeEmailGate();
  const resume = pendingAfterEmail;
  pendingAfterEmail = null;
  if (typeof resume === "function") resume();
}

/* ── "Add to Home Screen" hint ──
   Chrome/Android fires beforeinstallprompt → we drive a one-tap Install button.
   iOS Safari has no such API, so we show the manual Share → Add to Home Screen
   steps instead. Shown only on home, after setup, when not already installed
   and not previously dismissed. */
const INSTALL_DISMISS_KEY = "interviewPrepInstallDismissed";
let deferredInstallPrompt = null;

window.addEventListener("beforeinstallprompt", (e) => {
  e.preventDefault();
  deferredInstallPrompt = e;
  maybeShowInstallHint();
});
window.addEventListener("appinstalled", () => {
  deferredInstallPrompt = null;
  const el = document.getElementById("installHint");
  if (el) el.hidden = true;
});

function isStandalone() {
  return window.matchMedia("(display-mode: standalone)").matches || window.navigator.standalone === true;
}
function isIOS() {
  return /iphone|ipad|ipod/i.test(navigator.userAgent) && !window.MSStream;
}
function isAndroid() {
  return /android/i.test(navigator.userAgent);
}

/* Three presentations, so the hint is useful even when the browser never fires
   beforeinstallprompt (iOS always, Android often):
   1. native one-tap Install button (Chrome/Android/desktop fired the event),
   2. iOS Safari manual Share → Add to Home Screen steps,
   3. generic manual "browser menu → Add to Home screen" for any other phone. */
function maybeShowInstallHint() {
  const el = document.getElementById("installHint");
  if (!el) return;
  let dismissed = false;
  try { dismissed = localStorage.getItem(INSTALL_DISMISS_KEY) === "1"; } catch (e) {}
  const native = !!deferredInstallPrompt, ios = isIOS(), android = isAndroid();
  const canShow = isRegistered() && appView === "home" && !isStandalone() && !dismissed
    && (native || ios || android);
  if (!canShow) { el.hidden = true; return; }
  document.getElementById("installBtn").hidden = !native;
  document.getElementById("installHintAndroid").hidden = !native;         // pairs with the button
  document.getElementById("installHintIos").hidden = !(ios && !native);
  document.getElementById("installHintManual").hidden = !(!native && !ios); // Android/other, no native prompt
  el.hidden = false;
}

function dismissInstallHint() {
  try { localStorage.setItem(INSTALL_DISMISS_KEY, "1"); } catch (e) {}
  const el = document.getElementById("installHint");
  if (el) el.hidden = true;
}

async function triggerInstall() {
  if (!deferredInstallPrompt) return;
  deferredInstallPrompt.prompt();
  try { await deferredInstallPrompt.userChoice; } catch (e) {}
  deferredInstallPrompt = null;
  const el = document.getElementById("installHint");
  if (el) el.hidden = true;
}

/* Legacy magic-link sender — no longer used by the front door, kept for the
   optional cross-device login path. */
async function sendActivationEmail(email, name, phone, location) {
  if (!supabaseClient) return false;
  try {
    const options = { emailRedirectTo: window.location.origin + window.location.pathname, data: {} };
    if (name) options.data.name = name;
    if (phone) options.data.phone = phone;
    if (location) options.data.location = location;
    const { error } = await supabaseClient.auth.signInWithOtp({ email, options });
    if (error) throw error;
    return true;
  } catch (err) {
    console.error("Failed to send activation email:", err);
    return false;
  }
}

/* Swap the gate form for the "check your email" screen. Used both right
   after submitting and on a fresh page load if activation is still pending. */
function showActivationPending(email) {
  document.getElementById("gateForm").hidden = true;
  document.getElementById("gateLoginPrompt").hidden = true;
  document.getElementById("gateLoginBox").hidden = true;
  document.getElementById("gatePending").hidden = false;
  document.getElementById("gatePendingEmail").textContent = email;
}

function showRegistrationForm() {
  document.getElementById("gatePending").hidden = true;
  document.getElementById("gateForm").hidden = false;
  document.getElementById("gateLoginPrompt").hidden = false;
  try { localStorage.removeItem(PENDING_EMAIL_KEY); } catch (e) {}
}

async function gateSendLoginLink() {
  const email = document.getElementById("gateLoginEmail").value.trim();
  const msg = document.getElementById("gateLoginMsg");
  msg.hidden = true;
  if (!isValidEmail(email) || !supabaseClient) return;
  try {
    const { error } = await supabaseClient.auth.signInWithOtp({
      email,
      options: { emailRedirectTo: window.location.origin + window.location.pathname },
    });
    if (error) throw error;
    msg.textContent = gateText("gate.loginSent");
    msg.className = "gate__msg gate__msg--ok";
    msg.hidden = false;
  } catch (err) {
    msg.textContent = gateText("gate.err.save");
    msg.className = "gate__msg gate__msg--error";
    msg.hidden = false;
  }
}

async function loadStateOfficials() {
  if (!supabaseClient) return;
  try {
    const { data, error } = await supabaseClient.from("state_officials").select("*");
    if (error) throw error;
    stateOfficials = {};
    (data || []).forEach(o => { stateOfficials[o.code] = o; });
  } catch (err) {
    console.error("Failed to load state officials:", err);
  }
}

/* Returns "governor" | "senator" | "capital" if q is a state-specific civics
   question, else null. */
function localizableCivicsKind(q) {
  if (!q || q.category !== "naturalization") return null;
  const t = (q.question_en || "").trim().toLowerCase();
  return Object.keys(LOCALIZABLE_CIVICS).find(kind => LOCALIZABLE_CIVICS[kind] === t) || null;
}

/* Builds the localized answer for a signed-in user who has set their state,
   or null if we should fall back to the generic database answer. */
function buildLocalizedCivicsAnswer(kind, lang) {
  const meta = (currentUser && currentUser.user_metadata) || {};
  // Works for gate-registered users too: fall back to the locally saved state,
  // then to the state implied by their registration location.
  const code = meta.state || lsGet(PROFILE_STATE_KEY)
    || STATE_NAME_TO_CODE[meta.location] || STATE_NAME_TO_CODE[lsGet(REG_LOCATION_KEY)] || "";
  const o = code && stateOfficials[code];
  if (!o) return null;
  const name = o.name;
  const verify = lang === "vi"
    ? " ⚠ Hãy kiểm tra lại trước buổi phỏng vấn — thông tin này có thể thay đổi sau bầu cử."
    : " ⚠ Verify before your interview — this can change with elections.";

  if (kind === "governor") {
    if (!o.governor) return lang === "vi" ? `${name} không có thống đốc bang.` : `${name} does not have a governor.`;
    return (lang === "vi" ? `Thống đốc bang ${name}: ${o.governor}.` : `The Governor of ${name} is ${o.governor}.`) + verify;
  }
  if (kind === "senator") {
    const s = o.senators;
    if (!s || !s.length) return lang === "vi" ? `${name} không có Thượng Nghị Sĩ Hoa Kỳ.` : `${name} has no U.S. Senators.`;
    const joined = lang === "vi" ? s.join(" và ") : s.join(" and ");
    return (lang === "vi"
      ? `Hai Thượng Nghị Sĩ Hoa Kỳ của bang ${name} là ${joined} — nêu tên một trong hai là câu trả lời đúng.`
      : `${name}'s two U.S. Senators are ${joined} — naming either one is a correct answer.`) + verify;
  }
  if (kind === "capital") {
    if (!o.capital) return lang === "vi" ? `${name} không phải là một tiểu bang nên không có thủ phủ.` : `${name} is not a state, so it has no state capital.`;
    return lang === "vi" ? `Thủ phủ của bang ${name} là ${o.capital}.` : `The capital of ${name} is ${o.capital}.`;
  }
  return null;
}

function loadFlaggedIds() {
  try {
    const raw = localStorage.getItem(FLAG_STORAGE_KEY);
    return new Set(raw ? JSON.parse(raw) : []);
  } catch (err) {
    return new Set();
  }
}

function saveFlaggedIds() {
  localStorage.setItem(FLAG_STORAGE_KEY, JSON.stringify([...flaggedIds]));
}

function loadMissedIds() {
  try {
    const raw = localStorage.getItem(MISSED_STORAGE_KEY);
    return new Set(raw ? JSON.parse(raw) : []);
  } catch (err) {
    return new Set();
  }
}

function saveMissedIds() {
  localStorage.setItem(MISSED_STORAGE_KEY, JSON.stringify([...missedIds]));
}

// Count of civics questions currently on the missed list (drives the button count).
function countMissedCivics() {
  return allQuestions.filter(q => q.category === "naturalization" && missedIds.has(q.id)).length;
}

/* ── Spaced repetition (Leitner boxes) for missed civics questions ──
   Each missed question sits in a box (1 → 2 → 3). Answering it correctly
   promotes it to the next box and schedules it further out (now / +2 days /
   +5 days); a correct answer in box 3 clears it for good, and any wrong answer
   drops it back to box 1, due immediately. Scheduling metadata is device-local;
   the missed *list* still syncs across devices (restored questions simply come
   back due right away, then re-earn their schedule). */
const MISSED_META_KEY = "interviewPrepMissedMeta";
const LEITNER_DAYS = [0, 2, 5]; // due offset in days for boxes 1..3

function loadMissedMeta() {
  try { return JSON.parse(localStorage.getItem(MISSED_META_KEY)) || {}; }
  catch (e) { return {}; }
}
let missedMeta = loadMissedMeta();

function saveMissedMeta() {
  try { localStorage.setItem(MISSED_META_KEY, JSON.stringify(missedMeta)); } catch (e) {}
}

function setMissedBox(id, box) {
  missedMeta[id] = { b: box, d: localDateStamp(LEITNER_DAYS[box - 1]) };
  saveMissedMeta();
}

// No metadata (legacy or restored-from-server item) counts as due now.
function isMissedDue(id) {
  const m = missedMeta[id];
  return !m || m.d <= localDateStamp(0);
}

function dueMissedCivics() {
  return allQuestions.filter(q =>
    q.category === "naturalization" && missedIds.has(q.id) && isMissedDue(q.id)).length;
}

// Earliest upcoming due date among scheduled (not-yet-due) missed civics questions.
function nextMissedDueDate() {
  let min = null;
  allQuestions.forEach(q => {
    if (q.category !== "naturalization" || !missedIds.has(q.id)) return;
    const m = missedMeta[q.id];
    if (m && m.d > localDateStamp(0) && (!min || m.d < min)) min = m.d;
  });
  return min;
}

let lastResultsCache = [];

function initAuth() {
  if (!supabaseClient) return;
  supabaseClient.auth.onAuthStateChange((event, session) => {
    currentUser = session ? session.user : null;
    renderAccountUI();
    if (currentUser && (event === "SIGNED_IN" || event === "INITIAL_SESSION")) {
      // A logged-in user has already given us their details — skip the gate.
      markRegistered();
      closeGate();
      try { localStorage.removeItem(PENDING_EMAIL_KEY); } catch (e) {}
      // Only link identity on an actual sign-in transition, not every reload of
      // an existing session — identify() logs a 'register' event each call.
      if (event === "SIGNED_IN") identifyPerson({ email: currentUser.email });
      mergeLocalFlagsToAccount()
        .then(loadFlaggedIdsFromAccount)
        .then(mergeLocalMissedToAccount)
        .then(loadMissedIdsFromAccount)
        .then(loadRecentResults)
        .then(syncProgressAcrossDevices);
    }
  });
}

async function signInWithEmail(email, phone) {
  const sentMsg = document.getElementById("accountSentMsg");
  const errorMsg = document.getElementById("accountErrorMsg");
  sentMsg.hidden = true;
  errorMsg.hidden = true;
  if (!supabaseClient) return;

  try {
    const options = { emailRedirectTo: window.location.origin + window.location.pathname };
    if (phone) options.data = { phone };
    const { error } = await supabaseClient.auth.signInWithOtp({ email, options });
    if (error) throw error;
    sentMsg.hidden = false;
  } catch (err) {
    console.error("Failed to send magic link:", err);
    const fallback = currentLang === "vi" ? translations.vi["account.error"] : ACCOUNT_ERROR_EN;
    errorMsg.textContent = err.message || fallback;
    errorMsg.hidden = false;
  }
}

async function signOutUser() {
  try { if (supabaseClient) await supabaseClient.auth.signOut(); } catch (e) {}
  currentUser = null;
  // Clear the local registration so the start screen (gate) shows again. Keeps
  // the device client_id and saved progress so a re-register continues cleanly.
  try {
    [REGISTERED_STORAGE_KEY, REG_NAME_KEY, REG_EMAIL_KEY, REG_PHONE_KEY,
     REG_LOCATION_KEY, PROFILE_STATE_KEY].forEach(k => localStorage.removeItem(k));
  } catch (e) {}
  document.getElementById("accountPanel").hidden = true;
  renderAccountUI();
  showGateIfNeeded();
}

// Saves the profile's state selection (drives civics localization). Persists to
// localStorage for gate-registered users, and to auth metadata if signed in.
async function saveProfile() {
  const state = document.getElementById("accountStateInput").value;
  const savedMsg = document.getElementById("accountPhoneSavedMsg");
  try { localStorage.setItem(PROFILE_STATE_KEY, state || ""); } catch (e) {}
  if (currentUser && supabaseClient) {
    try {
      const { data, error } = await supabaseClient.auth.updateUser({ data: { state } });
      if (!error && data) currentUser = data.user;
    } catch (err) { console.error("Failed to save profile:", err); }
  }
  savedMsg.hidden = false;
  setTimeout(() => { savedMsg.hidden = true; }, 3000);
  if (quizSet.length && currentIndex < quizSet.length) renderCurrentQuestion();
}

function setAccountRow(id, text) {
  const el = document.getElementById(id);
  if (!el) return;
  el.textContent = text;
  el.hidden = !text;
}

function renderAccountUI() {
  const btnLabel = document.getElementById("accountBtnLabel");
  const loggedOutEl = document.getElementById("accountLoggedOut");
  const loggedInEl = document.getElementById("accountLoggedIn");
  const stateSelect = document.getElementById("accountStateInput");
  if (stateSelect && stateSelect.options.length) stateSelect.options[0].textContent = statePlaceholderText();

  // Profile info: prefer any auth metadata, else the gate registration on this device.
  const meta = (currentUser && currentUser.user_metadata) || {};
  const name = meta.name || lsGet(REG_NAME_KEY);
  const phone = meta.phone || lsGet(REG_PHONE_KEY);
  const location = lsGet(REG_LOCATION_KEY);

  if (isRegistered()) {
    btnLabel.textContent = name || (currentLang === "vi" ? "Hồ sơ" : "Profile");
    if (loggedOutEl) loggedOutEl.hidden = true;
    loggedInEl.hidden = false;
    setAccountRow("accountNameDisplay", name);
    setAccountRow("accountPhoneDisplay", phone ? "📞 " + phone : "");
    setAccountRow("accountLocationDisplay", location ? "📍 " + location : "");
    if (stateSelect) stateSelect.value = meta.state || lsGet(PROFILE_STATE_KEY) || STATE_NAME_TO_CODE[location] || "";
  } else {
    btnLabel.textContent = currentLang === "vi" ? translations.vi["account.login"] : "Log In";
    if (loggedOutEl) loggedOutEl.hidden = false;
    loggedInEl.hidden = true;
  }
  // Progress card visibility depends on login state.
  if (typeof renderProgress === "function") renderProgress();
}

async function mergeLocalFlagsToAccount() {
  if (!currentUser || !supabaseClient || flaggedIds.size === 0) return;
  const rows = [...flaggedIds].map(id => ({ user_id: currentUser.id, question_id: id }));
  try {
    await supabaseClient.from("flagged_questions").upsert(rows, { onConflict: "user_id,question_id" });
  } catch (err) {
    console.error("Failed to merge local flags into account:", err);
  }
}

async function loadFlaggedIdsFromAccount() {
  if (!currentUser || !supabaseClient) return;
  try {
    const { data, error } = await supabaseClient
      .from("flagged_questions")
      .select("question_id")
      .eq("user_id", currentUser.id);
    if (error) throw error;
    flaggedIds = new Set((data || []).map(r => r.question_id));
    saveFlaggedIds();
    if (quizSet.length && currentIndex < quizSet.length) renderFlagButton();
    if (currentCategory === "flagged") startRound("flagged");
  } catch (err) {
    console.error("Failed to load flagged questions from account:", err);
  }
}

async function mergeLocalMissedToAccount() {
  if (!currentUser || !supabaseClient || missedIds.size === 0) return;
  const rows = [...missedIds].map(id => ({ user_id: currentUser.id, question_id: id }));
  try {
    await supabaseClient.from("missed_questions").upsert(rows, { onConflict: "user_id,question_id" });
  } catch (err) {
    console.error("Failed to merge local missed questions into account:", err);
  }
}

async function loadMissedIdsFromAccount() {
  if (!currentUser || !supabaseClient) return;
  try {
    const { data, error } = await supabaseClient
      .from("missed_questions")
      .select("question_id")
      .eq("user_id", currentUser.id);
    if (error) throw error;
    missedIds = new Set((data || []).map(r => r.question_id));
    saveMissedIds();
    if (currentCategory === "naturalization") updateNaturalizationUI();
    if (reviewMode) startRound("naturalization");
  } catch (err) {
    console.error("Failed to load missed questions from account:", err);
  }
}

// Record a wrong (missed=true) or right (missed=false) answer against the
// spaced-repetition schedule: wrong resets the question to box 1 (due now),
// right promotes it a box — and clears it for good after box 3. Membership
// changes sync to the backend so the missed list follows the user.
async function markMissed(id, missed) {
  if (missed) {
    const wasListed = missedIds.has(id);
    missedIds.add(id);
    setMissedBox(id, 1);
    saveMissedIds();
    if (!wasListed) syncMissedUp(id, true);
  } else {
    if (!missedIds.has(id)) return; // never missed — nothing to schedule
    const box = ((missedMeta[id] && missedMeta[id].b) || 1) + 1;
    if (box > LEITNER_DAYS.length) {
      // Mastered: correct at the top box removes it from the review loop.
      missedIds.delete(id);
      delete missedMeta[id];
      saveMissedIds();
      saveMissedMeta();
      syncMissedUp(id, false);
    } else {
      setMissedBox(id, box);
    }
  }
  if (currentCategory === "naturalization") updateNaturalizationUI();
}

// ── Cross-device progress sync (flagged + missed), keyed by device client_id ──
function syncFlagUp(id, on) {
  if (!supabaseClient || !isRegistered() || IS_DEV_HOST) return;
  supabaseClient.rpc("save_flag", { p_client_id: getClientId(), p_question_id: id, p_flagged: on })
    .then(({ error }) => { if (error) console.error("save_flag:", error.message); });
}
function syncMissedUp(id, on) {
  if (!supabaseClient || !isRegistered() || IS_DEV_HOST) return;
  supabaseClient.rpc("save_missed", { p_client_id: getClientId(), p_question_id: id, p_missed: on })
    .then(({ error }) => { if (error) console.error("save_missed:", error.message); });
}
// Back up whatever is already flagged/missed on this device to the server.
function pushAllProgressUp() {
  if (!supabaseClient || !isRegistered()) return;
  flaggedIds.forEach(id => syncFlagUp(id, true));
  missedIds.forEach(id => syncMissedUp(id, true));
}
// On restore, pull this person's flagged/missed from any device and merge in,
// then push any local-only items up so all their devices converge.
async function pullProgressForContact(contact) {
  if (!supabaseClient || !contact) return;
  try {
    const [f, m] = await Promise.all([
      supabaseClient.rpc("get_my_flagged", { p_contact: contact }),
      supabaseClient.rpc("get_my_missed", { p_contact: contact }),
    ]);
    const serverFlags = (f.data || []).map(r => r.question_id);
    const serverMissed = (m.data || []).map(r => r.question_id);
    const localOnlyFlags = [...flaggedIds].filter(id => !serverFlags.includes(id));
    const localOnlyMissed = [...missedIds].filter(id => !serverMissed.includes(id));
    serverFlags.forEach(id => flaggedIds.add(id));
    serverMissed.forEach(id => missedIds.add(id));
    saveFlaggedIds();
    saveMissedIds();
    localOnlyFlags.forEach(id => syncFlagUp(id, true));
    localOnlyMissed.forEach(id => syncMissedUp(id, true));
    if (quizSet.length && currentIndex < quizSet.length) renderFlagButton();
    if (currentCategory === "naturalization") updateNaturalizationUI();
    // Bring the rounds / review counts over to this device too.
    await syncProgressAcrossDevices();
  } catch (err) {
    console.error("Failed to restore progress:", err);
  }
}

async function recordQuizResult(category, mode, correct, total) {
  // Save progress for EVERY registered user — on the device (works instantly
  // and offline). The backend practice_activity log is written once per round in
  // onRoundComplete() (which runs right after this), so we don't log it here.
  addLocalProgress(correct, total);

  // Signed-in users also get the cross-device quiz_results history.
  if (!currentUser || !supabaseClient) return;
  try {
    const { error } = await supabaseClient.from("quiz_results").insert({
      user_id: currentUser.id,
      category,
      mode,
      correct,
      total,
    });
    if (error) throw error;
    loadRecentResults();
  } catch (err) {
    console.error("Failed to save quiz result:", err);
  }
}

async function loadRecentResults() {
  if (!currentUser || !supabaseClient) return;
  try {
    const { data, error } = await supabaseClient
      .from("quiz_results")
      .select("*")
      .eq("user_id", currentUser.id)
      .order("taken_at", { ascending: false })
      .limit(365);
    if (error) throw error;
    lastResultsCache = data || [];
    renderRecentResults(lastResultsCache.slice(0, 8));
    renderProgress();
  } catch (err) {
    console.error("Failed to load recent results:", err);
  }
}

function renderRecentResults(rows) {
  const el = document.getElementById("accountResults");
  if (!el) return;
  if (!rows.length) {
    const empty = currentLang === "vi" ? translations.vi["account.noResults"] : ACCOUNT_NO_RESULTS_EN;
    el.innerHTML = `<p class="account-panel__result-empty">${empty}</p>`;
    return;
  }
  const title = currentLang === "vi" ? translations.vi["account.recentResults"] : ACCOUNT_RECENT_RESULTS_EN;
  const rowsHtml = rows.map(r => {
    const label = currentLang === "vi"
      ? (translations.vi["badge." + r.category] || r.category)
      : (CATEGORY_LABEL_EN[r.category] || r.category);
    const date = new Date(r.taken_at).toLocaleDateString(currentLang === "vi" ? "vi-VN" : "en-US", { month: "short", day: "numeric" });
    return `<div class="account-panel__result-row"><span>${label}</span><span>${r.correct}/${r.total} · ${date}</span></div>`;
  }).join("");
  el.innerHTML = `<p class="account-panel__results-title">${title}</p>${rowsHtml}`;
}

const enCache = {};
let currentLang = "en";
let allQuestions = [];
let currentCategory = "marriage";
let contentType = "question"; // "question" | "red_flag" | "checklist" — only meaningful for OPEN_FIELD categories
let spokenMode = false; // civics "Spoken Test" — answer aloud, auto-scored
// Naturalization quick actions (level 2 menu → level 3 single-action screens).
// natAction is null while the tile menu is showing.
let natAction = null;
let flashMode = false;   // "128 Civic Questions" — flip-card study deck
let mcTestMode = false;  // "Real Civics Test" — 20 random multiple choice, scored
let spokenVerdict = null; // true | false | null(=manual) for the current spoken question
let typedVerdict = null; // true | false | null(=manual) for the current typed (Simulate) question
let mcState = { qid: null, options: [], answeredIndex: null }; // Study multiple-choice state
let quizSet = [];
let currentIndex = 0;
let flaggedIds = loadFlaggedIds();
let missedIds = loadMissedIds();
let reviewMode = false; // civics "Review Missed" mode — quiz only your missed civics questions
let simMode = false;
let simScore = { correct: 0, total: 0 };
let simTimes = [];
let natTestType = "civics"; // "civics" | "english" — only meaningful while currentCategory === "naturalization"
let natEnglishSection = "eng_speaking"; // "eng_speaking" | "eng_reading" | "eng_writing"
// Marriage "Mock Interview" — record your spoken answer, play it back, self-rate.
// Open-ended answers can't be auto-scored, so this is a confidence-building loop.
let mockMode = false;
let mockRecorder = null, mockStream = null, mockChunks = [], mockBlobUrl = null;
let mockTimerInt = null, mockStartTs = 0, mockRatings = [];
const MOCK_MIN_Q = 5, MOCK_MAX_Q = 7, MOCK_MAX_SECONDS = 120;
// Categories whose whole question set is open-ended record-and-review.
// Naturalization joins via mockAvailable(): only its English → Speaking
// section (N-400-style personal questions) — civics keeps auto-scoring.
const MOCK_CATEGORIES = ["marriage", "asylum", "f1", "b1b2"];

// True when the current selection supports the Mock Interview flow.
function mockAvailable(category) {
  if (contentType !== "question") return false;
  if (MOCK_CATEGORIES.includes(category)) return true;
  return category === "naturalization" && natTestType === "english" && natEnglishSection === "eng_speaking";
}
let timerInterval = null;
let questionStartTime = 0;
let currentUser = null;

function isSelfScored() {
  return simMode || reviewMode || (currentCategory === "naturalization" && natTestType === "english");
}

function hasTimer() {
  return simMode;
}

function switchLanguage(lang) {
  const flag = document.getElementById("langFlag");
  const label = document.getElementById("langLabel");

  if (lang === "vi") {
    document.querySelectorAll("[data-i18n]").forEach(el => {
      const key = el.getAttribute("data-i18n");
      if (!enCache[key]) enCache[key] = el.innerHTML;
      if (translations.vi[key]) el.innerHTML = translations.vi[key];
    });
    flag.textContent = "🇺🇸";
    label.textContent = "English";
    document.documentElement.lang = "vi";
    currentLang = "vi";
  } else {
    document.querySelectorAll("[data-i18n]").forEach(el => {
      const key = el.getAttribute("data-i18n");
      if (enCache[key]) el.innerHTML = enCache[key];
    });
    flag.textContent = "🇻🇳";
    label.textContent = "Tiếng Việt";
    document.documentElement.lang = "en";
    currentLang = "en";
  }
  if (!document.getElementById("quizDone").hidden) renderDoneState(currentDoneKind);
  renderCurrentQuestion();
  renderAccountUI();
  renderGateLang();
  if (currentUser) renderRecentResults(lastResultsCache.slice(0, 8));
  setServiceHeaderTitle();
  renderProgress();
  renderNews();
  if (!document.getElementById("newsModal").hidden && currentNewsItem) openNewsModal(currentNewsItem);
  renderCountdown();
}

function shuffle(array) {
  const arr = [...array];
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
  return arr;
}

function updateNaturalizationUI() {
  // The naturalization quick-action menu replaced the civics/English, sim-mode,
  // and English-section toggles — each tile jumps straight to one mode, so the
  // in-quiz toggles stay hidden for naturalization.
  document.getElementById("natTestTypeToggle").hidden = true;
  document.getElementById("simToggle").hidden = true;
  document.getElementById("englishSectionToggle").hidden = true;
}

function categoryHasContent(category, type) {
  return allQuestions.some(q => q.category === category && (q.content_type || "question") === type);
}

function updateContentTypeToggle() {
  const toggle = document.getElementById("contentTypeToggle");
  // Green/Red Flags and Documents are quick-action tiles now for every main
  // category, so the in-quiz tab bar never shows.
  const isMain = false;
  const hasGreenFlags = isMain && categoryHasContent(currentCategory, "green_flag");
  const hasRedFlags = isMain && categoryHasContent(currentCategory, "red_flag");
  const hasChecklist = isMain && categoryHasContent(currentCategory, "checklist");
  toggle.hidden = !(isMain && (hasGreenFlags || hasRedFlags || hasChecklist));
  document.getElementById("greenFlagsTabBtn").hidden = !hasGreenFlags;
  document.getElementById("redFlagsTabBtn").hidden = !hasRedFlags;
  document.getElementById("documentsTabBtn").hidden = !hasChecklist;
  document.getElementById("questionsTabBtn").classList.toggle("sim-toggle__btn--active", contentType === "question");
  document.getElementById("greenFlagsTabBtn").classList.toggle("sim-toggle__btn--active", contentType === "green_flag");
  document.getElementById("redFlagsTabBtn").classList.toggle("sim-toggle__btn--active", contentType === "red_flag");
  document.getElementById("documentsTabBtn").classList.toggle("sim-toggle__btn--active", contentType === "checklist");
}

// The open-ended categories launch Mock Interview from its own quick-action
// tile now, so the Study/Mock toggle only remains inside naturalization's
// Speaking Test screen (where Mock shares the screen with flashcard-style study).
function updateMockToggle() {
  const toggle = document.getElementById("mockToggle");
  if (!toggle) return;
  const show = mockAvailable(currentCategory) && currentCategory === "naturalization";
  toggle.hidden = !show;
  if (show) {
    document.getElementById("mockStudyBtn").classList.toggle("sim-toggle__btn--active", !mockMode);
    document.getElementById("mockInterviewBtn").classList.toggle("sim-toggle__btn--active", mockMode);
  }
}

/* ── Home ↔ Service navigation ──
   Home shows the colorful service grid (+ progress for signed-in users).
   Picking a service focuses it: the grid is replaced by that service's
   quiz flow, and the only way to switch is via the Home button/logo. */
let appView = "home";                 // "home" | "service"
let currentServiceCategory = null;

const SERVICE_TOGGLE_IDS = ["contentTypeToggle", "natTestTypeToggle", "simToggle", "mockToggle", "englishSectionToggle"];

function setServiceHeaderTitle() {
  const el = document.getElementById("serviceHeaderTitle");
  if (!el || !currentServiceCategory) return;
  el.textContent = currentLang === "vi"
    ? (translations.vi["cat." + currentServiceCategory] || currentServiceCategory)
    : (CATEGORY_LABEL_EN[currentServiceCategory] || currentServiceCategory);
}

function showHome() {
  appView = "home";
  currentServiceCategory = null;
  clearInterval(timerInterval);
  document.getElementById("quickActions").hidden = true;
  document.getElementById("natBackBtn").hidden = true;
  document.getElementById("intro").hidden = false;
  document.getElementById("homeView").hidden = false;
  document.getElementById("serviceHeader").hidden = true;
  document.getElementById("quiz").hidden = true;
  SERVICE_TOGGLE_IDS.forEach(id => { const el = document.getElementById(id); if (el) el.hidden = true; });
  document.querySelectorAll(".service-card").forEach(c => c.classList.remove("service-card--active"));
  // Progress card is home-only.
  renderProgress();
  renderHomeGreeting();
  renderCountdown();
  renderBreakingBanner();
  maybeShowInstallHint();
  window.scrollTo({ top: 0, behavior: "smooth" });
}

function enterService(category) {
  if (!isRegistered()) { openGate(); return; }
  // Naturalization needs the user's state for its civics answers — ask once.
  if (category === "naturalization" && !hasLocation()) { openLocationGate(); return; }
  if (emailGateBlocks(() => enterService(category))) return;
  appView = "service";
  { const ih = document.getElementById("installHint"); if (ih) ih.hidden = true; }
  { const bb = document.getElementById("breakingBanner"); if (bb) bb.hidden = true; }
  currentServiceCategory = category;
  document.getElementById("intro").hidden = true;
  document.getElementById("homeView").hidden = true;
  const cta = document.getElementById("ctaLogin");
  if (cta) cta.hidden = true;
  const header = document.getElementById("serviceHeader");
  header.hidden = false;
  header.style.setProperty("--svc", `var(--svc-${category})`);
  setServiceHeaderTitle();
  contentType = "question";
  logActivity("view", category);
  // Main categories get the quick-action menu (level 2) instead of a round.
  if (MAIN_CATEGORIES.includes(category)) { showServiceMenu(category); return; }
  document.getElementById("quickActions").hidden = true;
  document.getElementById("natBackBtn").hidden = true;
  document.getElementById("quiz").hidden = false;
  if (!allQuestions.length) { document.getElementById("quizLoading").hidden = false; return; }
  startRound(category);
}

/* ── Quick actions ──
   Level 2: a flat tile menu of everything the service offers. Level 3: picking
   a tile shows only that mode; the back arrow returns to the menu.
   Naturalization has its own tile set; the open-ended categories share one. */
function showServiceMenu(category) {
  natAction = null;
  clearInterval(timerInterval);
  cleanupMockRecording();
  window.speechSynthesis && window.speechSynthesis.cancel();
  simMode = false; spokenMode = false; reviewMode = false; mockMode = false;
  flashMode = false; mcTestMode = false;
  natTestType = "civics"; contentType = "question";
  document.getElementById("quiz").hidden = true;
  document.getElementById("natBackBtn").hidden = true;
  SERVICE_TOGGLE_IDS.forEach(id => { const el = document.getElementById(id); if (el) el.hidden = true; });
  const isNat = category === "naturalization";
  document.getElementById("qaGridNat").hidden = !isNat;
  document.getElementById("qaGridOpen").hidden = isNat;
  if (isNat) {
    // Review Missed tile: spaced repetition drives what's due today. Show the
    // due count; when everything is scheduled for later, show the next due
    // date instead and gray the tile out.
    const total = countMissedCivics();
    const due = dueMissedCivics();
    const countEl = document.getElementById("qaReviewCount");
    if (due > 0) {
      countEl.textContent = `(${due})`;
    } else if (total > 0) {
      const nd = nextMissedDueDate();
      const d = nd ? new Date(nd + "T12:00:00").toLocaleDateString(currentLang === "vi" ? "vi-VN" : "en-US", { month: "short", day: "numeric" }) : "";
      countEl.textContent = currentLang === "vi" ? `· hẹn ${d}` : `· next ${d}`;
    }
    countEl.hidden = total === 0;
    const reviewTile = document.querySelector('.qa-tile[data-action="review"]');
    if (reviewTile) reviewTile.disabled = due === 0;
    // Spoken Test needs browser speech recognition.
    const spokenTile = document.querySelector('.qa-tile[data-action="spoken"]');
    if (spokenTile) spokenTile.disabled = !SPEECH_SUPPORTED;
  } else {
    // Only offer content the category actually has seeded.
    ["green_flag", "red_flag", "checklist"].forEach((type, i) => {
      const tile = document.querySelector(`#qaGridOpen [data-action="${["green", "red", "docs"][i]}"]`);
      if (tile) tile.hidden = !categoryHasContent(category, type);
    });
  }
  // Tiles pick up the service's identity color (emerald for naturalization).
  document.getElementById("quickActions").style.setProperty("--svc", `var(--svc-${category})`);
  document.getElementById("quickActions").hidden = false;
  window.scrollTo({ top: 0, behavior: "smooth" });
}

function startServiceAction(action) {
  if (!isRegistered()) { openGate(); return; }
  // Starting a round from a tile counts like any other round start for the
  // email-capture funnel.
  if (emailGateBlocks(() => startServiceAction(action))) return;
  if (!allQuestions.length) return;
  const category = currentServiceCategory;
  if (!MAIN_CATEGORIES.includes(category)) return;
  natAction = action;
  simMode = false; spokenMode = false; reviewMode = false; mockMode = false;
  flashMode = false; mcTestMode = false;
  natTestType = "civics"; contentType = "question";
  if (category === "naturalization") {
    switch (action) {
      case "flash": flashMode = true; break;
      case "mctest": simMode = true; mcTestMode = true; break;
      case "spoken": simMode = true; spokenMode = true; break;
      case "review": reviewMode = true; break;
      case "speaking": natTestType = "english"; natEnglishSection = "eng_speaking"; break;
      case "reading": natTestType = "english"; natEnglishSection = "eng_reading"; break;
      case "writing": natTestType = "english"; natEnglishSection = "eng_writing"; break;
      case "green": contentType = "green_flag"; break;
      case "red": contentType = "red_flag"; break;
    }
  } else {
    switch (action) {
      case "mock": mockMode = true; break;
      case "green": contentType = "green_flag"; break;
      case "red": contentType = "red_flag"; break;
      case "docs": contentType = "checklist"; break;
      // "questions" is the default flags-off state.
    }
  }
  document.getElementById("quickActions").hidden = true;
  document.getElementById("natBackBtn").hidden = false;
  document.getElementById("quiz").hidden = false;
  startRound(category);
}

/* Aggregate correct/wrong across all saved quiz rounds for the progress card. */
function renderProgress() {
  const card = document.getElementById("progressCard");
  if (!card) return;
  // Signed-in users: use their cross-device backend history. Everyone else who
  // has registered: use the on-device progress log (no login needed).
  let correct, total, rounds, reviewed;
  const catCounts = {};                     // category → rounds practiced
  if (currentUser && (lastResultsCache || []).length) {
    const rows = lastResultsCache;
    correct = rows.reduce((s, r) => s + (r.correct || 0), 0);
    total = rows.reduce((s, r) => s + (r.total || 0), 0);
    rounds = rows.length;
    reviewed = total;                       // signed-in history is all scored tests
    rows.forEach(r => { if (r.category) catCounts[r.category] = (catCounts[r.category] || 0) + 1; });
  } else {
    const p = loadLocalProgress();
    correct = p.correct; total = p.total; rounds = p.rounds; reviewed = p.reviewed;
    Object.keys(p.cats).forEach(k => { catCounts[k] = p.cats[k].rounds || 0; });
  }
  const show = isRegistered() && appView === "home" && rounds > 0;
  card.hidden = !show;
  if (!show) return;
  // Rounds + questions reviewed apply to all practice; accuracy only exists once
  // there's a scored test (civics Test mode / English test) to average.
  const pct = total ? Math.round((correct / total) * 100) : null;
  document.getElementById("statRounds").textContent = rounds;
  document.getElementById("statReviewed").textContent = reviewed;
  document.getElementById("statAccuracy").textContent = pct === null ? "—" : pct + "%";
  const tmpl = currentLang === "vi" ? translations.vi["progress.sub"] : PROGRESS_SUB_EN;
  document.getElementById("progressSub").textContent = tmpl.replace("{rounds}", rounds);
  // Category chips — which services they've practiced, most-practiced first.
  const catsEl = document.getElementById("progressCats");
  const catsWrap = document.getElementById("progressCatsWrap");
  if (catsEl) {
    const entries = Object.entries(catCounts).filter(([, n]) => n > 0).sort((a, b) => b[1] - a[1]);
    catsEl.innerHTML = entries.map(([cat, n]) =>
      `<span class="progress-cat">${catLabelFor(cat)}<b>${n}</b></span>`).join("");
    if (catsWrap) catsWrap.hidden = entries.length === 0;
  }
}

function setContentType(type) {
  if (!isRegistered()) { openGate(); return; }
  if (emailGateBlocks(() => setContentType(type))) return;
  contentType = type;
  startRound(currentCategory);
}

function setSimMode(on) {
  simMode = on;
  spokenMode = false;
  reviewMode = false;
  startRound("naturalization");
}

function setSpokenTest() {
  simMode = true;
  spokenMode = true;
  reviewMode = false;
  startRound("naturalization");
}

function setReviewMode() {
  simMode = false;
  spokenMode = false;
  reviewMode = true;
  startRound("naturalization");
}

function setNatTestType(type) {
  natTestType = type;
  simMode = false;
  spokenMode = false;
  reviewMode = false;
  startRound("naturalization");
}

function setMockMode(on) {
  mockMode = on;
  simMode = false;
  spokenMode = false;
  reviewMode = false;
  contentType = "question";
  startRound(currentCategory);
}

function setEnglishSection(section) {
  natEnglishSection = section;
  startRound("naturalization");
}

function startRound(category) {
  clearInterval(timerInterval);
  cleanupMockRecording();
  currentCategory = category;
  if (category !== "naturalization") {
    simMode = false; spokenMode = false; reviewMode = false; natTestType = "civics";
    flashMode = false; mcTestMode = false; natAction = null;
  }
  // Mock interview applies only where mockAvailable() allows it.
  if (!mockAvailable(category)) mockMode = false;
  if (!MAIN_CATEGORIES.includes(category)) contentType = "question";
  updateNaturalizationUI();
  updateContentTypeToggle();
  updateMockToggle();

  let pool;
  if (category === "flagged") pool = allQuestions.filter(q => flaggedIds.has(q.id));
  // Green Flags / Red Flags / Documents — same handling for every main category
  // (including naturalization), which bypasses the civics/English test flow.
  else if (contentType !== "question") {
    pool = allQuestions.filter(q => q.category === category && (q.content_type || "question") === contentType);
  } else if (category === "naturalization" && natTestType === "civics" && reviewMode) {
    // Spaced repetition: only quiz what's due today (no metadata = due).
    pool = allQuestions.filter(q => q.category === "naturalization" && missedIds.has(q.id) && isMissedDue(q.id));
  } else if (category === "naturalization") {
    const dbCategory = natTestType === "english" ? natEnglishSection : "naturalization";
    pool = allQuestions.filter(q => q.category === dbCategory && (q.content_type || "question") === "question");
  } else pool = allQuestions.filter(q => q.category === category && (q.content_type || "question") === contentType);

  quizSet = shuffle(pool);
  if (category === "naturalization" && natTestType === "civics" && simMode) quizSet = quizSet.slice(0, SIM_QUESTION_COUNT);
  if (mockMode && mockAvailable(category)) {
    const n = MOCK_MIN_Q + Math.floor(Math.random() * (MOCK_MAX_Q - MOCK_MIN_Q + 1));
    quizSet = quizSet.slice(0, n);
    mockRatings = [];
  }
  simScore = { correct: 0, total: 0 };
  simTimes = [];
  currentIndex = 0;

  document.getElementById("quizDone").hidden = true;
  document.getElementById("quizCard").hidden = quizSet.length === 0;

  if (quizSet.length === 0) {
    renderDoneState(category === "flagged" ? "flaggedEmpty" : (reviewMode ? "reviewEmpty" : "finished"));
    document.getElementById("quizDone").hidden = false;
  } else {
    renderCurrentQuestion();
  }
}

let currentDoneKind = "finished";

function formatDuration(ms) {
  const totalSec = Math.round(ms / 1000);
  const m = Math.floor(totalSec / 60);
  const s = totalSec % 60;
  return m > 0 ? `${m}:${String(s).padStart(2, "0")}` : `${s}s`;
}

function renderDoneState(kind) {
  currentDoneKind = kind;
  const badgeEl = document.getElementById("simResultBadge");
  const timingEl = document.getElementById("simResultTiming");
  const textEl = document.getElementById("quizDoneText");
  const restartBtn = document.getElementById("restartBtn");
  const iconEl = document.getElementById("quizDoneIcon");

  badgeEl.classList.remove("sim-result-badge--pass", "sim-result-badge--fail", "sim-result-badge--warn");
  timingEl.hidden = true;

  if (kind === "simResult") {
    const passed = simScore.correct >= SIM_PASS_THRESHOLD;
    const template = currentLang === "vi"
      ? translations.vi[passed ? "sim.pass" : "sim.fail"]
      : (passed ? SIM_PASS_EN : SIM_FAIL_EN);
    badgeEl.textContent = template
      .replace("{correct}", simScore.correct)
      .replace("{total}", simScore.total)
      .replace("{threshold}", SIM_PASS_THRESHOLD);
    badgeEl.classList.add(passed ? "sim-result-badge--pass" : "sim-result-badge--fail");
    badgeEl.hidden = false;
    textEl.hidden = true;
    iconEl.className = passed ? "fa-solid fa-circle-check" : "fa-solid fa-triangle-exclamation";
    iconEl.style.color = passed ? "" : "#dc2626";
    if (simTimes.length) {
      const totalMs = simTimes.reduce((a, b) => a + b, 0);
      const avgMs = totalMs / simTimes.length;
      const timingTemplate = currentLang === "vi" ? translations.vi["sim.timing"] : SIM_TIMING_EN;
      timingEl.textContent = timingTemplate
        .replace("{total}", formatDuration(totalMs))
        .replace("{avg}", formatDuration(avgMs));
      timingEl.hidden = false;
    }
    restartBtn.innerHTML = currentLang === "vi" ? translations.vi["btn.tryAgain"] : '<i class="fa-solid fa-rotate-right"></i> Try Another Random Set';
    restartBtn.style.display = "";
  } else if (kind === "englishResult") {
    const pct = simScore.total ? Math.round((simScore.correct / simScore.total) * 100) : 0;
    let level, cls;
    if (pct >= 90) { level = "excellent"; cls = "pass"; }
    else if (pct >= 70) { level = "good"; cls = "warn"; }
    else { level = "needsPractice"; cls = "fail"; }
    const template = currentLang === "vi" ? translations.vi["eng.result." + level] : ENGLISH_RESULT_EN[level];
    badgeEl.textContent = template.replace("{pct}", pct);
    badgeEl.classList.add("sim-result-badge--" + cls);
    badgeEl.hidden = false;
    textEl.hidden = true;
    iconEl.className = cls === "fail" ? "fa-solid fa-triangle-exclamation" : "fa-solid fa-circle-check";
    iconEl.style.color = cls === "fail" ? "#dc2626" : (cls === "warn" ? "#d97706" : "");
    restartBtn.innerHTML = currentLang === "vi" ? translations.vi["btn.tryAgain"] : '<i class="fa-solid fa-rotate-right"></i> Try Another Random Set';
    restartBtn.style.display = "";
  } else if (kind === "reviewDone") {
    const cleared = simScore.correct;
    const remaining = dueMissedCivics(); // still-due today; promoted questions return on their schedule
    const template = currentLang === "vi" ? translations.vi["review.done"] : REVIEW_DONE_EN;
    badgeEl.textContent = template
      .replace("{cleared}", cleared)
      .replace("{total}", simScore.total)
      .replace("{remaining}", remaining);
    badgeEl.classList.add(remaining === 0 ? "sim-result-badge--pass" : "sim-result-badge--warn");
    badgeEl.hidden = false;
    textEl.hidden = true;
    iconEl.className = remaining === 0 ? "fa-solid fa-circle-check" : "fa-solid fa-rotate-right";
    iconEl.style.color = "";
    restartBtn.innerHTML = currentLang === "vi" ? translations.vi["review.again"] : '<i class="fa-solid fa-rotate-right"></i> Review Again';
    restartBtn.style.display = remaining === 0 ? "none" : "";
  } else {
    badgeEl.hidden = true;
    textEl.hidden = false;
    textEl.textContent = DONE_MESSAGES[kind][currentLang];
    iconEl.className = "fa-solid fa-circle-check";
    iconEl.style.color = "";
    restartBtn.innerHTML = currentLang === "vi" ? translations.vi["btn.restart"] : '<i class="fa-solid fa-rotate-right"></i> Start Over';
    restartBtn.style.display = (kind === "flaggedEmpty" || kind === "reviewEmpty") ? "none" : "";
  }
}

function renderCurrentQuestion() {
  if (!quizSet.length || currentIndex >= quizSet.length) return;
  const q = quizSet[currentIndex];
  const ct = q.content_type || "question";

  // Color the card green for green flags, red for red flags (styled in CSS).
  const card = document.getElementById("quizCard");
  card.classList.toggle("quiz__card--green-flag", ct === "green_flag");
  card.classList.toggle("quiz__card--red-flag", ct === "red_flag");

  const badge = document.getElementById("quizBadge");
  const progress = document.getElementById("quizProgress");
  const questionEl = document.getElementById("quizQuestion");
  const writingPromptEl = document.getElementById("quizWritingPrompt");
  const answerLabelEl = document.getElementById("quizAnswerLabel");
  const answerTextEl = document.getElementById("quizAnswerText");
  const answerBox = document.getElementById("quizAnswer");

  badge.textContent = currentLang === "vi"
    ? translations.vi["badge." + q.category]
    : CATEGORY_LABEL_EN[q.category];
  if (simMode) badge.textContent += currentLang === "vi" ? translations.vi["sim.badgeSuffix"] : SIM_BADGE_SUFFIX_EN;
  if (reviewMode) badge.textContent += currentLang === "vi" ? translations.vi["review.badgeSuffix"] : REVIEW_BADGE_SUFFIX_EN;
  if (mockMode) badge.textContent += currentLang === "vi" ? " · Phỏng Vấn Thử" : " · Mock Interview";
  if (flashMode) badge.textContent += currentLang === "vi" ? " · Thẻ Ghi Nhớ" : " · Flashcards";
  if (ct !== "question") badge.textContent += currentLang === "vi" ? translations.vi["content.badge." + ct] : CONTENT_BADGE_SUFFIX_EN[ct];

  // Mock mode never scores, so skip the "{correct} of {answered}" progress
  // even where the underlying section (nat English) is normally self-scored.
  if (isSelfScored() && !mockMode) {
    const template = currentLang === "vi" ? translations.vi["sim.progress"] : SIM_PROGRESS_EN;
    progress.textContent = template
      .replace("{current}", currentIndex + 1)
      .replace("{total}", quizSet.length)
      .replace("{correct}", simScore.correct)
      .replace("{answered}", simScore.total);
  } else {
    let progressTemplate;
    if (ct !== "question") progressTemplate = currentLang === "vi" ? translations.vi["content.progress." + ct] : CONTENT_PROGRESS_EN[ct];
    else progressTemplate = currentLang === "vi" ? translations.vi["progress"] : "Question {current} of {total}";
    progress.textContent = progressTemplate
      .replace("{current}", currentIndex + 1)
      .replace("{total}", quizSet.length);
  }

  const isWriting = q.category === "eng_writing";
  questionEl.textContent = currentLang === "vi" ? q.question_vi : q.question_en;
  questionEl.hidden = isWriting || flashMode; // flashcards show the question on the card's front face
  writingPromptEl.hidden = !isWriting;
  document.getElementById("quizTtsRow").hidden = !(isWriting && "speechSynthesis" in window);

  if (ct !== "question") {
    answerLabelEl.textContent = currentLang === "vi"
      ? translations.vi["content.answerLabel." + ct]
      : CONTENT_ANSWER_LABEL_EN[ct];
  } else {
    answerLabelEl.textContent = currentLang === "vi"
      ? translations.vi["answer.label." + q.category]
      : ANSWER_LABEL_EN[q.category];
  }
  answerTextEl.textContent = currentLang === "vi" ? q.answer_vi : q.answer_en;

  // For a signed-in user who has set their state, replace the generic
  // "look it up" answer on the state-specific civics questions with the
  // correct localized answer (Governor / Senators / state capital).
  const civicsKind = localizableCivicsKind(q);
  if (civicsKind) {
    const localized = buildLocalizedCivicsAnswer(civicsKind, currentLang);
    if (localized) answerTextEl.textContent = localized;
  }

  answerBox.hidden = true;
  renderFlagButton();
  renderActionButtons();
  renderTimer();
  if (mockMode && mockAvailable(currentCategory)) enterMockAsk(q);
  else if (flashMode) enterFlashCard(q);
  else if (simMode && spokenMode) enterSpokenAsk(q);
  else if (simMode && mcTestMode) renderChoices(q);
  else if (simMode && !spokenMode) enterTypedAsk(q);
  else if (studyMCActive(q)) renderChoices(q);
}

function renderActionButtons() {
  const q = quizSet[currentIndex];
  const spoken = simMode && spokenMode;     // Spoken Test — answer aloud
  const typed = simMode && !spokenMode && !mcTestMode; // Simulate — typed answer (legacy)
  const mc = (simMode && mcTestMode) || studyMCActive(q); // multiple choice (test or study)
  const mock = mockMode && mockAvailable(currentCategory); // Mock Interview — record & review
  const flash = flashMode;                   // Flashcards — flip/sound/nav
  const selfScored = isSelfScored();
  document.getElementById("quizSpoken").hidden = !spoken;
  document.getElementById("quizTyped").hidden = !typed;
  document.getElementById("quizChoices").hidden = !mc;
  document.getElementById("quizMock").hidden = !mock;
  document.getElementById("quizFlash").hidden = !flash;
  // spoken/typed/mc/mock/flash handle their own flow; hide the plain reveal button.
  document.getElementById("revealBtn").hidden = spoken || typed || mc || mock || flash;
  // Next shows for plain reveal; for MC it's toggled on after a choice (renderChoices).
  document.getElementById("nextBtn").hidden = selfScored || spoken || typed || mc || mock || flash;
  // I Knew It / I Missed It only for the remaining self-scored modes (English, Review).
  document.getElementById("gotItBtn").hidden = !selfScored || spoken || typed || mc || mock || flash;
  document.getElementById("missedBtn").hidden = !selfScored || spoken || typed || mc || mock || flash;
}

// Reset the spoken card to its "ask" phase and read the question aloud.
function enterSpokenAsk(q) {
  spokenVerdict = null;
  document.getElementById("spokenAsk").hidden = false;
  document.getElementById("spokenResult").hidden = true;
  document.getElementById("quizListening").hidden = true;
  document.getElementById("micBtn").disabled = false;
  document.getElementById("quizTranscriptText").textContent = "";
  document.getElementById("quizAnswer").hidden = true;
  speakText(q.question_en);
}

function startListening() {
  if (!SPEECH_SUPPORTED) return;
  const rec = new SpeechRec();
  rec.lang = "en-US";
  rec.interimResults = false;
  rec.maxAlternatives = 4;
  document.getElementById("quizListening").hidden = false;
  document.getElementById("micBtn").disabled = true;
  window.speechSynthesis && window.speechSynthesis.cancel();

  rec.onresult = (e) => {
    const alts = [];
    for (const result of e.results) {
      for (let i = 0; i < result.length; i++) alts.push(result[i].transcript);
    }
    handleSpokenResult(alts);
  };
  rec.onerror = () => showSpokenError();
  rec.onend = () => {
    document.getElementById("quizListening").hidden = true;
    document.getElementById("micBtn").disabled = false;
  };
  try { rec.start(); } catch (err) { showSpokenError(); }
}

function handleSpokenResult(alts) {
  const q = quizSet[currentIndex];
  document.getElementById("quizTranscriptText").textContent = (alts[0] || "…");
  const verdict = isCivicsAutoScorable(q) ? gradeCivicsAnswer(alts, q.answer_en) : null;
  showSpokenResult(verdict);
}

function showSpokenResult(verdict) {
  document.getElementById("spokenAsk").hidden = true;
  document.getElementById("spokenResult").hidden = false;
  document.getElementById("quizAnswer").hidden = false; // reveal the official answer

  const vEl = document.getElementById("quizVerdict");
  const correctBtn = document.getElementById("spokenCorrectBtn");
  const wrongBtn = document.getElementById("spokenWrongBtn");
  vEl.classList.remove("quiz__verdict--pass", "quiz__verdict--fail", "quiz__verdict--neutral");
  correctBtn.classList.remove("btn--suggested");
  wrongBtn.classList.remove("btn--suggested");

  if (verdict === true) {
    vEl.textContent = currentLang === "vi" ? translations.vi["spoken.verdict.pass"] : SPOKEN_EN.verdictPass;
    vEl.classList.add("quiz__verdict--pass");
    correctBtn.classList.add("btn--suggested");
  } else if (verdict === false) {
    vEl.textContent = currentLang === "vi" ? translations.vi["spoken.verdict.fail"] : SPOKEN_EN.verdictFail;
    vEl.classList.add("quiz__verdict--fail");
    wrongBtn.classList.add("btn--suggested");
  } else {
    vEl.textContent = currentLang === "vi" ? translations.vi["spoken.verdict.manual"] : SPOKEN_EN.verdictManual;
    vEl.classList.add("quiz__verdict--neutral");
  }
  spokenVerdict = verdict;
}

function showSpokenError() {
  document.getElementById("quizListening").hidden = true;
  document.getElementById("micBtn").disabled = false;
  showSpokenResult(null);
  document.getElementById("quizVerdict").textContent =
    currentLang === "vi" ? translations.vi["spoken.error"] : SPOKEN_EN.error;
}

function escapeHtml(s) {
  return (s || "").replace(/[&<>"']/g, c => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]));
}

// ── Study multiple choice ──────────────────────────────────────────────
// Shown only in civics Study mode, for questions with a fixed correct answer.
function studyMCActive(q) {
  return !simMode && !reviewMode && !spokenMode && !flashMode
    && currentCategory === "naturalization" && natTestType === "civics"
    && contentType === "question"
    && !!q && q.category === "naturalization" && (q.content_type || "question") === "question"
    && isCivicsAutoScorable(q);
}

// Concise option label: first acceptable variant, parentheticals and trailing
// punctuation removed (e.g. "Twenty-seven (27)." → "Twenty-seven").
function optionText(answer) {
  let v = (answer || "").split(/;|\n/)[0] || "";
  v = v.replace(/\([^)]*\)/g, " ").replace(/\s+/g, " ").trim();
  return v.replace(/[.;,]+$/, "").trim();
}

// Number words used to detect answers that are a count, duration, or year
// so those questions only ever offer numeric choices.
const NUM_WORD = "(?:zero|one|two|three|four|five|six|seven|eight|nine|ten|" +
  "eleven|twelve|thirteen|fourteen|fifteen|sixteen|seventeen|eighteen|" +
  "nineteen|twenty|thirty|forty|fifty|sixty|seventy|eighty|ninety|hundred|thousand)";

// True when the concise answer is essentially a number, duration, or date
// (e.g. "One hundred", "Six years", "435", "July 4, 1776") — not merely a
// phrase that happens to contain a year like "War of 1812".
function isNumericAnswer(text) {
  let s = (text || "").toLowerCase().trim();
  if (/^\d{4}$/.test(s)) return true;                         // a year on its own
  if (/^[a-z]+ \d{1,2},? \d{4}$/.test(s)) return true;        // "july 4, 1776"
  s = s.replace(/[.,]/g, "").replace(/-/g, " ").replace(/\s+/g, " ").trim();
  const re = new RegExp(`^${NUM_WORD}( ${NUM_WORD})*( (?:years?|days?|months?|stars?|stripes?))?$`);
  return re.test(s) || /^\d+( years?)?$/.test(s);
}

// True when the correct answer is a specific person's name, so the distractors
// should also be people's names rather than concepts or numbers. The official
// civics answers that are a bare name all come from these question stems —
// including the current-officials questions (President / Vice President /
// Speaker / Chief Justice "now"), whose answers hold real names since the
// update_current_officials.sql migration.
function isPersonAnswer(q) {
  const s = (q.question_en || "").toLowerCase();
  return /\bwho wrote\b/.test(s)
    || /\bwho was president\b/.test(s)
    || /name one of the writers/.test(s)
    || /name one leader of the women/.test(s)
    || /name of the president of the united states now/.test(s)
    || /name of the vice president of the united states now/.test(s)
    || /speaker of the house of representatives now/.test(s)
    || /chief justice of the united states now/.test(s);
}

// Coarse answer type used to keep multiple-choice distractors the same kind as
// the correct answer (names→names, numbers→numbers, everything else→text).
function answerType(q) {
  if (isPersonAnswer(q)) return "person";
  if (isNumericAnswer(optionText(q.answer_en))) return "number";
  return "text";
}

// Correct answer + 3 distractors drawn from other civics answers, shuffled.
// Distractors are matched to the correct answer's type first (so a "name"
// question offers names and a "number" question offers numbers), then any
// remaining slots are filled from the rest of the pool.
function buildChoices(q) {
  const correctText = optionText(q.answer_en).toLowerCase();
  const correctType = answerType(q);
  const pool = shuffle(allQuestions.filter(o =>
    o.category === "naturalization" && o.id !== q.id && isCivicsAutoScorable(o)));
  const distractors = [];
  const seen = new Set([correctText]);
  // Pass 1: same answer type as the correct answer. Pass 2: fill remaining
  // slots from the other types so there are always four choices.
  for (const sameType of [true, false]) {
    for (const o of pool) {
      if (distractors.length === 3) break;
      if (sameType !== (answerType(o) === correctType)) continue;
      const t = optionText(o.answer_en).toLowerCase();
      if (!t || seen.has(t)) continue;
      seen.add(t);
      distractors.push({ q: o, correct: false });
    }
    if (distractors.length === 3) break;
  }
  mcState = { qid: q.id, options: shuffle([{ q, correct: true }, ...distractors]), answeredIndex: null };
}

function renderChoices(q) {
  if (mcState.qid !== q.id) buildChoices(q);
  const answered = mcState.answeredIndex !== null;
  const keys = ["A", "B", "C", "D"];
  document.getElementById("quizChoicesList").innerHTML = mcState.options.map((opt, i) => {
    const text = optionText(currentLang === "vi" ? opt.q.answer_vi : opt.q.answer_en);
    let cls = "quiz__choice";
    if (answered) {
      if (opt.correct) cls += " quiz__choice--correct";
      else if (i === mcState.answeredIndex) cls += " quiz__choice--wrong";
      else cls += " quiz__choice--dim";
    }
    return `<button class="${cls}" data-choice="${i}"${answered ? " disabled" : ""}>` +
      `<span class="quiz__choice-key">${keys[i]}</span><span>${escapeHtml(text)}</span></button>`;
  }).join("");
  document.getElementById("quizChoices").hidden = false;
  document.getElementById("quizAnswer").hidden = !answered; // reveal official answer after choosing
  document.getElementById("nextBtn").hidden = !answered;
}

function selectChoice(idx) {
  if (mcState.answeredIndex !== null) return;
  mcState.answeredIndex = idx;
  // Real Civics Test: multiple choice is scored toward the 12/20 result and
  // feeds adaptive review, unlike the unscored study MC.
  if (simMode && mcTestMode) {
    stopTimerAndRecord();
    const correct = !!mcState.options[idx].correct;
    simScore.total++;
    if (correct) simScore.correct++;
    const q = quizSet[currentIndex];
    if (q && q.category === "naturalization") markMissed(q.id, !correct);
  }
  renderChoices(quizSet[currentIndex]);
}

// ── Civics flashcards (128 questions: flip / sound / flag / prev-next) ──
function enterFlashCard(q) {
  document.getElementById("flashCard").classList.remove("is-flipped");
  // Faces mirror the already-rendered (and state-localized) question/answer text.
  document.getElementById("flashQuestionText").textContent = document.getElementById("quizQuestion").textContent;
  document.getElementById("flashAnswerText").textContent = document.getElementById("quizAnswerText").textContent;
  document.getElementById("quizAnswer").hidden = true;
  document.getElementById("flashPrevBtn").disabled = currentIndex === 0;
}

function flipFlashCard() {
  document.getElementById("flashCard").classList.toggle("is-flipped");
}

// Read the visible face aloud — always in English (the interview language),
// with the state-localized civics answer where one applies.
function speakFlashCard() {
  const q = quizSet[currentIndex];
  if (!q) return;
  const flipped = document.getElementById("flashCard").classList.contains("is-flipped");
  if (!flipped) { speakText(q.question_en); return; }
  const kind = localizableCivicsKind(q);
  const localized = kind ? buildLocalizedCivicsAnswer(kind, "en") : null;
  speakText(localized || q.answer_en);
}

function flashPrev() {
  if (currentIndex === 0) return;
  currentIndex--;
  renderCurrentQuestion();
}

// ── Simulate: typed answer (auto-scored) ───────────────────────────────
function enterTypedAsk(q) {
  typedVerdict = null;
  const input = document.getElementById("typedInput");
  input.value = "";
  input.placeholder = currentLang === "vi" ? translations.vi["typed.placeholder"] : "Type your answer…";
  document.getElementById("typedAsk").hidden = false;
  document.getElementById("typedResult").hidden = true;
  document.getElementById("typedEcho").textContent = "";
  document.getElementById("quizAnswer").hidden = true;
  input.focus();
}

function submitTyped() {
  const q = quizSet[currentIndex];
  const val = document.getElementById("typedInput").value.trim();
  if (!val) return;
  document.getElementById("typedEcho").textContent = val;
  const verdict = isCivicsAutoScorable(q) ? gradeCivicsAnswer([val], q.answer_en) : null;
  showTypedResult(verdict);
}

function showTypedResult(verdict) {
  document.getElementById("typedAsk").hidden = true;
  document.getElementById("typedResult").hidden = false;
  document.getElementById("quizAnswer").hidden = false; // reveal the official answer
  const vEl = document.getElementById("typedVerdict");
  const correctBtn = document.getElementById("typedCorrectBtn");
  const wrongBtn = document.getElementById("typedWrongBtn");
  vEl.classList.remove("quiz__verdict--pass", "quiz__verdict--fail", "quiz__verdict--neutral");
  correctBtn.classList.remove("btn--suggested");
  wrongBtn.classList.remove("btn--suggested");
  if (verdict === true) {
    vEl.textContent = currentLang === "vi" ? translations.vi["spoken.verdict.pass"] : TYPED_EN.verdictPass;
    vEl.classList.add("quiz__verdict--pass");
    correctBtn.classList.add("btn--suggested");
  } else if (verdict === false) {
    vEl.textContent = currentLang === "vi" ? translations.vi["spoken.verdict.fail"] : TYPED_EN.verdictFail;
    vEl.classList.add("quiz__verdict--fail");
    wrongBtn.classList.add("btn--suggested");
  } else {
    vEl.textContent = currentLang === "vi" ? translations.vi["spoken.verdict.manual"] : TYPED_EN.verdictManual;
    vEl.classList.add("quiz__verdict--neutral");
  }
  typedVerdict = verdict;
}

function renderTimer() {
  const timerEl = document.getElementById("quizTimer");
  clearInterval(timerInterval);
  if (!hasTimer()) {
    timerEl.hidden = true;
    return;
  }
  timerEl.hidden = false;
  questionStartTime = Date.now();
  updateTimerDisplay();
  timerInterval = setInterval(updateTimerDisplay, 200);
}

function updateTimerDisplay() {
  const timerEl = document.getElementById("quizTimer");
  const secs = Math.floor((Date.now() - questionStartTime) / 1000);
  timerEl.textContent = "⏱ " + secs + "s";
}

function stopTimerAndRecord() {
  if (!hasTimer()) return;
  clearInterval(timerInterval);
  simTimes.push(Date.now() - questionStartTime);
}

function playCurrentSentence() {
  if (!("speechSynthesis" in window)) return;
  const q = quizSet[currentIndex];
  if (!q) return;
  window.speechSynthesis.cancel();
  const utter = new SpeechSynthesisUtterance(q.question_en);
  utter.lang = "en-US";
  utter.rate = 0.9;
  window.speechSynthesis.speak(utter);
}

function renderFlagButton() {
  const flagBtn = document.getElementById("flagBtn");
  const icon = flagBtn.querySelector("i");
  const q = quizSet[currentIndex];
  const flagged = flaggedIds.has(q.id);

  flagBtn.classList.toggle("is-flagged", flagged);
  icon.className = flagged ? "fa-solid fa-star" : "fa-regular fa-star";
  flagBtn.setAttribute("aria-label", translations.vi["flag.ariaLabel"] && currentLang === "vi"
    ? translations.vi["flag.ariaLabel"]
    : "Flag for review");
}

async function toggleFlagCurrentQuestion() {
  if (!quizSet.length || currentIndex >= quizSet.length) return;
  const q = quizSet[currentIndex];
  const nowFlagged = !flaggedIds.has(q.id);

  if (nowFlagged) flaggedIds.add(q.id);
  else flaggedIds.delete(q.id);
  saveFlaggedIds();
  renderFlagButton();
  syncFlagUp(q.id, nowFlagged);
}

function revealAnswer() {
  document.getElementById("quizAnswer").hidden = false;
  document.getElementById("quizQuestion").hidden = false;
  document.getElementById("quizWritingPrompt").hidden = true;
}

// ── Marriage Mock Interview: record → play back → self-rate ─────────────
// Audio never leaves the device (an in-memory blob URL); we only log that a
// mock round happened, so the dashboard's Practice conversion reflects it.
function enterMockAsk(q) {
  cleanupMockRecording();
  document.getElementById("quizMock").hidden = false;
  document.getElementById("mockRecordPhase").hidden = false;
  document.getElementById("mockRecording").hidden = true;
  document.getElementById("mockReviewPhase").hidden = true;
  document.getElementById("mockRecordBtn").hidden = false;
  document.getElementById("mockRecordBtn").disabled = false;
  document.getElementById("mockError").hidden = true;
  document.getElementById("quizAnswer").hidden = true;
  const tips = document.getElementById("mockTipsText");
  if (tips) tips.textContent = currentLang === "vi" ? q.answer_vi : q.answer_en;
  const det = document.getElementById("mockTips");
  if (det) det.open = false;
  speakText(q.question_en);
}

async function startMockRecording() {
  const errEl = document.getElementById("mockError");
  errEl.hidden = true;
  if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia || !window.MediaRecorder) {
    errEl.hidden = false; return;
  }
  try {
    mockStream = await navigator.mediaDevices.getUserMedia({ audio: true });
  } catch (err) {
    errEl.hidden = false; return;
  }
  mockChunks = [];
  try { mockRecorder = new MediaRecorder(mockStream); }
  catch (err) { errEl.hidden = false; return; }
  mockRecorder.ondataavailable = (e) => { if (e.data && e.data.size) mockChunks.push(e.data); };
  mockRecorder.onstop = finalizeMockRecording;
  mockRecorder.start();
  window.speechSynthesis && window.speechSynthesis.cancel();
  document.getElementById("mockRecordBtn").hidden = true;
  document.getElementById("mockRecording").hidden = false;
  mockStartTs = Date.now();
  const t = document.getElementById("mockTimer");
  t.textContent = "0:00";
  clearInterval(mockTimerInt);
  mockTimerInt = setInterval(() => {
    const s = Math.floor((Date.now() - mockStartTs) / 1000);
    t.textContent = Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0");
    if (s >= MOCK_MAX_SECONDS) stopMockRecording();
  }, 250);
}

function stopMockRecording() {
  clearInterval(mockTimerInt);
  if (mockRecorder && mockRecorder.state !== "inactive") {
    try { mockRecorder.stop(); } catch (e) {}
  }
}

function finalizeMockRecording() {
  clearInterval(mockTimerInt);
  const type = (mockRecorder && mockRecorder.mimeType) || "audio/webm";
  if (mockStream) { mockStream.getTracks().forEach(t => t.stop()); mockStream = null; }
  if (mockBlobUrl) { URL.revokeObjectURL(mockBlobUrl); mockBlobUrl = null; }
  mockBlobUrl = URL.createObjectURL(new Blob(mockChunks, { type }));
  document.getElementById("mockAudio").src = mockBlobUrl;
  document.getElementById("mockRecordPhase").hidden = true;
  document.getElementById("mockRecording").hidden = true;
  document.getElementById("mockReviewPhase").hidden = false;
}

function redoMock() {
  const q = quizSet[currentIndex];
  if (q) enterMockAsk(q);
}

function rateMock(rating) {
  mockRatings.push(rating);
  cleanupMockRecording();
  nextQuestion();
}

// Stop any in-flight recording and release the mic.
function cleanupMockRecording() {
  clearInterval(mockTimerInt);
  if (mockRecorder && mockRecorder.state !== "inactive") {
    try { mockRecorder.onstop = null; mockRecorder.stop(); } catch (e) {}
  }
  mockRecorder = null;
  if (mockStream) { mockStream.getTracks().forEach(t => t.stop()); mockStream = null; }
}

function renderMockDone() {
  const badgeEl = document.getElementById("simResultBadge");
  const timingEl = document.getElementById("simResultTiming");
  const textEl = document.getElementById("quizDoneText");
  const restartBtn = document.getElementById("restartBtn");
  const iconEl = document.getElementById("quizDoneIcon");
  badgeEl.classList.remove("sim-result-badge--pass", "sim-result-badge--fail", "sim-result-badge--warn");
  const conf = mockRatings.filter(r => r === "confident").length;
  const okay = mockRatings.filter(r => r === "okay").length;
  const needs = mockRatings.filter(r => r === "needs_work").length;
  const total = mockRatings.length;
  badgeEl.textContent = currentLang === "vi"
    ? `Đã luyện ${total} câu · Tự tin ${conf} · Ổn ${okay} · Cần cải thiện ${needs}`
    : `Practiced ${total} · Confident ${conf} · Okay ${okay} · Needs work ${needs}`;
  badgeEl.classList.add(total > 0 && needs === 0 ? "sim-result-badge--pass" : "sim-result-badge--warn");
  badgeEl.hidden = false;
  timingEl.hidden = true;
  textEl.hidden = false;
  textEl.textContent = currentLang === "vi"
    ? "Nghe lại chính giọng mình giúp bạn tự tin hơn khi phỏng vấn. Hãy luyện thường xuyên!"
    : "Hearing your own answers back builds real interview confidence. Practice a fresh set often!";
  iconEl.className = "fa-solid fa-circle-check";
  iconEl.style.color = "";
  restartBtn.innerHTML = currentLang === "vi" ? translations.vi["btn.tryAgain"] : '<i class="fa-solid fa-rotate-right"></i> New Random Set';
  restartBtn.style.display = "";
}

function nextQuestion() {
  // Advancing past the free preview question requires registering.
  if (!isRegistered()) { openGate(); return; }
  currentIndex++;
  if (currentIndex >= quizSet.length) {
    if (mockMode && mockAvailable(currentCategory)) {
      cleanupMockRecording();
      renderMockDone();
      document.getElementById("quizCard").hidden = true;
      document.getElementById("quizDone").hidden = false;
      onRoundComplete({ mode: "mock", content_type: "question" });
      return;
    }
    let kind = "finished";
    if (simMode) kind = "simResult";
    else if (reviewMode) kind = "reviewDone";
    else if (isSelfScored()) kind = "englishResult";
    const isScored = (kind === "simResult" || kind === "englishResult");
    if (isScored) {
      recordQuizResult(
        simMode ? "naturalization" : natEnglishSection,
        simMode ? "simulate" : "english",
        simScore.correct,
        simScore.total
      );
    }
    renderDoneState(kind);
    document.getElementById("quizCard").hidden = true;
    document.getElementById("quizDone").hidden = false;
    onRoundComplete(isScored
      ? { mode: simMode ? "simulate" : "english", correct: simScore.correct, total: simScore.total }
      : {});
  } else {
    renderCurrentQuestion();
  }
}

function recordSimAnswer(correct) {
  const q = quizSet[currentIndex];
  stopTimerAndRecord();
  simScore.total++;
  if (correct) simScore.correct++;
  // Adaptive review: track civics misses, and clear a question once it's right.
  if (q && q.category === "naturalization") markMissed(q.id, !correct);
  nextQuestion();
}

async function loadQuestions() {
  const loadingEl = document.getElementById("quizLoading");
  const errorEl = document.getElementById("quizError");

  if (!supabaseClient) {
    loadingEl.hidden = true;
    errorEl.hidden = false;
    return;
  }

  try {
    const { data, error } = await supabaseClient.from("questions").select("*");
    if (error) throw error;
    if (!data || data.length === 0) throw new Error("empty");

    allQuestions = data;
    loadingEl.hidden = true;
    // If the user tapped a service before questions finished loading, start it;
    // otherwise land on the home grid.
    if (appView === "service" && currentServiceCategory) startRound(currentServiceCategory);
    else showHome();
  } catch (err) {
    console.error("Failed to load questions:", err);
    loadingEl.hidden = true;
    errorEl.hidden = false;
  }
}

document.addEventListener("DOMContentLoaded", () => {
  // Snapshot original English markup for every translated element up front,
  // before any dynamic mutation (e.g. the sim-result restart button label)
  // can happen — otherwise the lazy cache in switchLanguage() could capture
  // a mutated state as if it were the pristine original.
  document.querySelectorAll("[data-i18n]").forEach(el => {
    enCache[el.getAttribute("data-i18n")] = el.innerHTML;
  });

  document.getElementById("langToggle").addEventListener("click", () => {
    switchLanguage(currentLang === "en" ? "vi" : "en");
  });

  // ── Registration gate wiring ──
  document.getElementById("gateForm").addEventListener("submit", submitRegistration);
  // Naturalization-only location gate.
  document.getElementById("locationForm").addEventListener("submit", submitNatLocation);
  document.getElementById("locationCancel").addEventListener("click", (e) => {
    e.preventDefault();
    closeLocationGate();   // back out to the home categories (already behind the modal)
  });
  document.getElementById("gateLangToggle").addEventListener("click", () => {
    switchLanguage(currentLang === "en" ? "vi" : "en");
  });
  document.getElementById("gateLoginLink").addEventListener("click", (e) => {
    e.preventDefault();
    document.getElementById("gateLoginBox").hidden = false;
    document.getElementById("gateLoginEmail").focus();
  });
  document.getElementById("gateLoginSend").addEventListener("click", restoreFromContact);
  document.getElementById("gateLoginEmail").addEventListener("keydown", (e) => {
    if (e.key === "Enter") { e.preventDefault(); restoreFromContact(); }
  });
  document.getElementById("gateWelcomeContinue").addEventListener("click", enterAppAfterGate);

  document.getElementById("gateResendBtn").addEventListener("click", async () => {
    const email = document.getElementById("gatePendingEmail").textContent;
    const btn = document.getElementById("gateResendBtn");
    const msg = document.getElementById("gateResendMsg");
    btn.disabled = true;
    let name, phone, location;
    try {
      name = localStorage.getItem(REG_NAME_KEY);
      phone = localStorage.getItem(REG_PHONE_KEY);
      location = localStorage.getItem(REG_LOCATION_KEY);
    } catch (e) {}
    const sent = await sendActivationEmail(email, name, phone, location);
    btn.disabled = false;
    msg.hidden = false;
    msg.className = sent ? "gate__msg gate__msg--ok" : "gate__msg gate__msg--error";
    msg.textContent = gateText(sent ? "gate.resendSent" : "gate.err.save");
  });
  document.getElementById("gateUseDifferentEmail").addEventListener("click", (e) => {
    e.preventDefault();
    showRegistrationForm();
  });

  document.getElementById("serviceGrid").addEventListener("click", (e) => {
    const btn = e.target.closest(".service-card");
    if (!btn) return;
    // Picking a service counts as moving past the free preview — gate first.
    if (!isRegistered()) { openGate(); return; }
    enterService(btn.dataset.category);
  });

  // Home button and logo both return to the service grid.
  document.getElementById("homeBtn").addEventListener("click", showHome);
  document.getElementById("homeLogoLink").addEventListener("click", (e) => { e.preventDefault(); showHome(); });

  // Quick actions: tiles enter an action, the back arrow returns to the menu.
  document.querySelectorAll(".qa-tile").forEach(t =>
    t.addEventListener("click", () => startServiceAction(t.dataset.action)));
  document.getElementById("natBackBtn").addEventListener("click", () =>
    showServiceMenu(currentServiceCategory || "naturalization"));

  // Flashcards: tap the card (or the Flip button) to flip it.
  document.getElementById("flashCard").addEventListener("click", flipFlashCard);
  document.getElementById("flashFlipBtn").addEventListener("click", flipFlashCard);
  document.getElementById("flashSoundBtn").addEventListener("click", speakFlashCard);
  document.getElementById("flashPrevBtn").addEventListener("click", flashPrev);
  document.getElementById("flashNextBtn").addEventListener("click", nextQuestion);

  document.getElementById("questionsTabBtn").addEventListener("click", () => setContentType("question"));
  document.getElementById("greenFlagsTabBtn").addEventListener("click", () => setContentType("green_flag"));
  document.getElementById("redFlagsTabBtn").addEventListener("click", () => setContentType("red_flag"));
  document.getElementById("documentsTabBtn").addEventListener("click", () => setContentType("checklist"));

  document.getElementById("revealBtn").addEventListener("click", revealAnswer);
  document.getElementById("nextBtn").addEventListener("click", nextQuestion);
  document.getElementById("restartBtn").addEventListener("click", () => {
    if (emailGateBlocks(() => startRound(currentCategory))) return;
    startRound(currentCategory);
  });
  // ── Feedback card wiring ──
  document.querySelectorAll("#feedbackCard .fb-scale").forEach((row) => {
    row.addEventListener("click", (e) => {
      const b = e.target.closest("button[data-val]");
      if (b) selectFbScale(row.dataset.row, Number(b.dataset.val), b);
    });
  });
  document.getElementById("feedbackSend").addEventListener("click", submitFeedback);
  document.getElementById("feedbackSkip").addEventListener("click", skipFeedback);
  document.getElementById("feedbackReopen").addEventListener("click", (e) => { e.preventDefault(); openFeedback(); });
  // ── Email capture wiring (soft card + hard gate) ──
  document.getElementById("captureSubmit").addEventListener("click", submitEmailCapture);
  document.getElementById("captureEmail").addEventListener("keydown", (e) => {
    if (e.key === "Enter") { e.preventDefault(); submitEmailCapture(); }
  });
  document.getElementById("captureSkip").addEventListener("click", (e) => { e.preventDefault(); skipEmailCapture(); });
  // ── Install hint wiring ──
  document.getElementById("installBtn").addEventListener("click", triggerInstall);
  document.getElementById("installClose").addEventListener("click", dismissInstallHint);
  // ── Interview countdown wiring ──
  document.getElementById("interviewDateSave").addEventListener("click", saveInterviewDate);
  document.getElementById("countdownSnooze").addEventListener("click", (e) => { e.preventDefault(); snoozeCountdown(); });
  document.getElementById("countdownEdit").addEventListener("click", (e) => { e.preventDefault(); editInterviewDate(); });
  document.getElementById("countdownClear").addEventListener("click", (e) => { e.preventDefault(); clearInterviewDate(); });
  // ── News: cards, breaking banner, and the detail modal ──
  const newsItemBySlot = (slot) => newsItems.find(n => String(n.slot) === String(slot)) || null;
  document.getElementById("newsCards").addEventListener("click", (e) => {
    if (e.target.closest("a")) return; // source links navigate; card body opens the modal
    const card = e.target.closest(".news-card");
    if (card) openNewsModal(newsItemBySlot(card.dataset.slot));
  });
  document.getElementById("newsCards").addEventListener("keydown", (e) => {
    if (e.key !== "Enter" && e.key !== " ") return;
    const card = e.target.closest(".news-card");
    if (card) { e.preventDefault(); openNewsModal(newsItemBySlot(card.dataset.slot)); }
  });
  document.getElementById("breakingBanner").addEventListener("click", () => openNewsModal(featuredNews()));
  document.getElementById("newsModalClose").addEventListener("click", closeNewsModal);
  document.getElementById("newsModalBackdrop").addEventListener("click", closeNewsModal);
  document.getElementById("newsModalFaqList").addEventListener("click", (e) => {
    const q = e.target.closest(".news-faq__q");
    if (q) q.parentElement.classList.toggle("news-faq--open");
  });
  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape" && !document.getElementById("newsModal").hidden) closeNewsModal();
  });
  document.getElementById("emailGateForm").addEventListener("submit", submitEmailGate);
  document.getElementById("emailGateLangToggle").addEventListener("click", () => {
    switchLanguage(currentLang === "en" ? "vi" : "en");
  });
  document.getElementById("flagBtn").addEventListener("click", toggleFlagCurrentQuestion);
  document.getElementById("gotItBtn").addEventListener("click", () => recordSimAnswer(true));
  document.getElementById("missedBtn").addEventListener("click", () => recordSimAnswer(false));
  document.getElementById("practiceModeBtn").addEventListener("click", () => setSimMode(false));
  document.getElementById("simModeBtn").addEventListener("click", () => setSimMode(true));
  document.getElementById("spokenTestBtn").addEventListener("click", setSpokenTest);
  document.getElementById("reviewMissedBtn").addEventListener("click", setReviewMode);
  // ── Marriage Mock Interview wiring ──
  document.getElementById("mockStudyBtn").addEventListener("click", () => setMockMode(false));
  document.getElementById("mockInterviewBtn").addEventListener("click", () => setMockMode(true));
  document.getElementById("mockHearBtn").addEventListener("click", () => {
    const q = quizSet[currentIndex];
    if (q) speakText(q.question_en);
  });
  document.getElementById("mockRecordBtn").addEventListener("click", startMockRecording);
  document.getElementById("mockStopBtn").addEventListener("click", stopMockRecording);
  document.getElementById("mockRedoBtn").addEventListener("click", redoMock);
  document.querySelector(".quiz__mock-rate").addEventListener("click", (e) => {
    const btn = e.target.closest("[data-rating]");
    if (btn) rateMock(btn.dataset.rating);
  });
  document.getElementById("micBtn").addEventListener("click", startListening);
  document.getElementById("repeatQuestionBtn").addEventListener("click", () => {
    const q = quizSet[currentIndex];
    if (q) speakText(q.question_en);
  });
  document.getElementById("spokenCorrectBtn").addEventListener("click", () => recordSimAnswer(true));
  document.getElementById("spokenWrongBtn").addEventListener("click", () => recordSimAnswer(false));
  document.getElementById("quizChoicesList").addEventListener("click", (e) => {
    const btn = e.target.closest("[data-choice]");
    if (btn) selectChoice(Number(btn.dataset.choice));
  });
  document.getElementById("submitTypedBtn").addEventListener("click", submitTyped);
  document.getElementById("typedInput").addEventListener("keydown", (e) => {
    if (e.key === "Enter") submitTyped();
  });
  document.getElementById("typedCorrectBtn").addEventListener("click", () => recordSimAnswer(true));
  document.getElementById("typedWrongBtn").addEventListener("click", () => recordSimAnswer(false));
  document.getElementById("civicsTestBtn").addEventListener("click", () => setNatTestType("civics"));
  document.getElementById("englishTestBtn").addEventListener("click", () => setNatTestType("english"));
  document.getElementById("speakingSectionBtn").addEventListener("click", () => setEnglishSection("eng_speaking"));
  document.getElementById("readingSectionBtn").addEventListener("click", () => setEnglishSection("eng_reading"));
  document.getElementById("writingSectionBtn").addEventListener("click", () => setEnglishSection("eng_writing"));
  document.getElementById("playSentenceBtn").addEventListener("click", playCurrentSentence);

  document.getElementById("accountBtn").addEventListener("click", (e) => {
    e.stopPropagation();
    document.getElementById("accountPanel").hidden = !document.getElementById("accountPanel").hidden;
  });
  document.addEventListener("click", (e) => {
    const panel = document.getElementById("accountPanel");
    const btn = document.getElementById("accountBtn");
    if (!panel.hidden && !panel.contains(e.target) && !btn.contains(e.target)) panel.hidden = true;
  });
  document.getElementById("accountSavePhoneBtn").addEventListener("click", saveProfile);
  document.getElementById("accountLogoutBtn").addEventListener("click", signOutUser);

  populateStateSelect();
  renderGateLang();
  // Slim welcome on load — one tap to start (unless already registered on this
  // device or logged in, which initAuth also handles). Location is asked later,
  // only when Naturalization is opened.
  showGateIfNeeded();
  loadStateOfficials();
  renderAccountUI();
  initAuth();
  loadQuestions();
  loadNews();
  syncProgressAcrossDevices();   // adopt cross-device rounds/counts for returning devices
  logFirstTouchIfNeeded();
  logEvent("page_view");
  maybeShowInstallHint();   // iOS Safari (no beforeinstallprompt) + returning users
});

// Register the service worker so the app is installable ("Add to Home Screen")
// and works offline. Code (HTML/CSS/JS) is served network-first (see sw.js), so
// deploys always load the latest version. Data still comes live from Supabase.
if ("serviceWorker" in navigator) {
  window.addEventListener("load", () => {
    navigator.serviceWorker.register("sw.js").catch((err) => {
      console.warn("Service worker registration failed:", err);
    });
  });
}
