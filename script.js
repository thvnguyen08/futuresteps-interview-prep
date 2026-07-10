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

/* ── Translations (static UI strings only; question/answer text comes
   from the database's *_en / *_vi columns) ── */
const translations = {
  vi: {
    "header.subtitle": "Ôn Phỏng Vấn",
    "intro.tag": "Luyện Tập Phỏng Vấn",
    "intro.title": 'Chuẩn Bị Cho <em>Buổi Phỏng Vấn Di Trú</em> Của Bạn',
    "intro.desc": "Luyện tập với các câu hỏi mà viên chức thường hỏi. Chọn một danh mục, tự kiểm tra, và xem gợi ý hoặc đáp án khi bạn sẵn sàng.",
    "cta.title": "Tiếp tục ngay từ chỗ bạn đã dừng",
    "cta.sub": "Đăng nhập bằng email để lưu tiến trình và đồng bộ câu hỏi đã đánh dấu cùng kết quả trên mọi thiết bị của bạn.",
    "cta.btn": '<i class="fa-regular fa-envelope"></i> Đăng Nhập',
    "cat.marriage": "Thẻ Xanh Diện Hôn Nhân",
    "cat.naturalization": "Thi Quốc Tịch",
    "cat.asylum": "Phỏng Vấn Tị Nạn",
    "cat.f1": "Visa Du Học F-1",
    "cat.b1b2": "Visa Du Lịch/Công Tác B1/B2",
    "cat.flagged": "Đã Đánh Dấu",
    "content.questions": "Câu Hỏi Luyện Tập",
    "content.redFlags": "Điều Cần Tránh",
    "content.documents": "Giấy Tờ Cần Mang",
    "content.badge.red_flag": " — Điều Cần Tránh",
    "content.badge.checklist": " — Giấy Tờ",
    "content.answerLabel.red_flag": "Vì Sao Quan Trọng / Cách Xử Lý",
    "content.answerLabel.checklist": "Vì Sao Cần Thiết",
    "content.progress.red_flag": "Điều cần tránh {current}/{total}",
    "content.progress.checklist": "Giấy tờ {current}/{total}",
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
const ACCOUNT_RECENT_RESULTS_EN = "Recent Results";
const ENGLISH_RESULT_EN = {
  excellent: "🌟 Excellent — {pct}% correct. You're ready for the English portion of the interview!",
  good: "👍 Good — {pct}% correct. Review a bit more before your interview.",
  needsPractice: "📚 Needs Practice — {pct}% correct. Keep practicing speaking, reading, and writing.",
};

/* Categories that use the Practice Questions / Red Flags / Documents toggle. */
const OPEN_FIELD = ["marriage", "asylum", "f1", "b1b2"];
const CONTENT_BADGE_SUFFIX_EN = { red_flag: " — Red Flags", checklist: " — Documents" };
const CONTENT_ANSWER_LABEL_EN = { red_flag: "Why It Matters / How to Handle", checklist: "Why It Matters" };
const CONTENT_PROGRESS_EN = { red_flag: "Red flag {current} of {total}", checklist: "Document {current} of {total}" };

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
};

const FLAG_STORAGE_KEY = "interviewPrepFlaggedIds";

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
  const code = (currentUser && currentUser.user_metadata && currentUser.user_metadata.state) || "";
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

let lastResultsCache = [];

function initAuth() {
  if (!supabaseClient) return;
  supabaseClient.auth.onAuthStateChange((event, session) => {
    currentUser = session ? session.user : null;
    renderAccountUI();
    if (currentUser && (event === "SIGNED_IN" || event === "INITIAL_SESSION")) {
      mergeLocalFlagsToAccount()
        .then(loadFlaggedIdsFromAccount)
        .then(loadRecentResults);
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
  if (!supabaseClient) return;
  await supabaseClient.auth.signOut();
  document.getElementById("accountPanel").hidden = true;
}

async function saveProfile() {
  if (!currentUser || !supabaseClient) return;
  const phone = document.getElementById("accountPhoneInputLoggedIn").value.trim();
  const state = document.getElementById("accountStateInput").value;
  const savedMsg = document.getElementById("accountPhoneSavedMsg");
  try {
    const { data, error } = await supabaseClient.auth.updateUser({ data: { phone, state } });
    if (error) throw error;
    currentUser = data.user;
    savedMsg.hidden = false;
    setTimeout(() => { savedMsg.hidden = true; }, 3000);
    // If the user is currently on a state-specific civics question, refresh it
    // so the newly-saved state's answer shows immediately.
    if (quizSet.length && currentIndex < quizSet.length) renderCurrentQuestion();
  } catch (err) {
    console.error("Failed to save profile:", err);
  }
}

function renderAccountUI() {
  const btnLabel = document.getElementById("accountBtnLabel");
  const loggedOutEl = document.getElementById("accountLoggedOut");
  const loggedInEl = document.getElementById("accountLoggedIn");
  const emailDisplay = document.getElementById("accountEmailDisplay");
  const phoneInput = document.getElementById("accountPhoneInput");
  const phoneInputLoggedIn = document.getElementById("accountPhoneInputLoggedIn");
  const phonePlaceholder = currentLang === "vi" ? translations.vi["account.phonePlaceholder"] : "Phone number (optional)";
  phoneInput.placeholder = phonePlaceholder;
  phoneInputLoggedIn.placeholder = phonePlaceholder;
  const stateSelect = document.getElementById("accountStateInput");
  if (stateSelect && stateSelect.options.length) stateSelect.options[0].textContent = statePlaceholderText();

  const ctaLogin = document.getElementById("ctaLogin");

  if (currentUser) {
    btnLabel.textContent = currentUser.email;
    loggedOutEl.hidden = true;
    loggedInEl.hidden = false;
    emailDisplay.textContent = currentUser.email;
    phoneInputLoggedIn.value = (currentUser.user_metadata && currentUser.user_metadata.phone) || "";
    const stateInput = document.getElementById("accountStateInput");
    if (stateInput) stateInput.value = (currentUser.user_metadata && currentUser.user_metadata.state) || "";
    if (ctaLogin) ctaLogin.hidden = true;
  } else {
    btnLabel.textContent = currentLang === "vi" ? translations.vi["account.login"] : "Log In";
    loggedOutEl.hidden = false;
    loggedInEl.hidden = true;
    if (ctaLogin) ctaLogin.hidden = false;
  }
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

async function recordQuizResult(category, mode, correct, total) {
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
      .limit(10);
    if (error) throw error;
    lastResultsCache = data || [];
    renderRecentResults(lastResultsCache);
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
let spokenVerdict = null; // true | false | null(=manual) for the current spoken question
let quizSet = [];
let currentIndex = 0;
let flaggedIds = loadFlaggedIds();
let simMode = false;
let simScore = { correct: 0, total: 0 };
let simTimes = [];
let natTestType = "civics"; // "civics" | "english" — only meaningful while currentCategory === "naturalization"
let natEnglishSection = "eng_speaking"; // "eng_speaking" | "eng_reading" | "eng_writing"
let timerInterval = null;
let questionStartTime = 0;
let currentUser = null;

function isSelfScored() {
  return simMode || (currentCategory === "naturalization" && natTestType === "english");
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
  if (currentUser) renderRecentResults(lastResultsCache);
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
  const isNat = currentCategory === "naturalization";
  document.getElementById("natTestTypeToggle").hidden = !isNat;
  document.getElementById("civicsTestBtn").classList.toggle("sim-toggle__btn--active", natTestType === "civics");
  document.getElementById("englishTestBtn").classList.toggle("sim-toggle__btn--active", natTestType === "english");

  const showCivicsSub = isNat && natTestType === "civics";
  document.getElementById("simToggle").hidden = !showCivicsSub;
  document.getElementById("practiceModeBtn").classList.toggle("sim-toggle__btn--active", !simMode);
  document.getElementById("simModeBtn").classList.toggle("sim-toggle__btn--active", simMode && !spokenMode);
  const spokenBtn = document.getElementById("spokenTestBtn");
  spokenBtn.hidden = !(showCivicsSub && SPEECH_SUPPORTED);
  spokenBtn.classList.toggle("sim-toggle__btn--active", simMode && spokenMode);

  const showEnglishSub = isNat && natTestType === "english";
  document.getElementById("englishSectionToggle").hidden = !showEnglishSub;
  document.getElementById("speakingSectionBtn").classList.toggle("sim-toggle__btn--active", natEnglishSection === "eng_speaking");
  document.getElementById("readingSectionBtn").classList.toggle("sim-toggle__btn--active", natEnglishSection === "eng_reading");
  document.getElementById("writingSectionBtn").classList.toggle("sim-toggle__btn--active", natEnglishSection === "eng_writing");
}

function categoryHasContent(category, type) {
  return allQuestions.some(q => q.category === category && (q.content_type || "question") === type);
}

function updateContentTypeToggle() {
  const toggle = document.getElementById("contentTypeToggle");
  const isOpenField = OPEN_FIELD.includes(currentCategory);
  const hasRedFlags = isOpenField && categoryHasContent(currentCategory, "red_flag");
  const hasChecklist = isOpenField && categoryHasContent(currentCategory, "checklist");
  toggle.hidden = !(isOpenField && (hasRedFlags || hasChecklist));
  document.getElementById("redFlagsTabBtn").hidden = !hasRedFlags;
  document.getElementById("documentsTabBtn").hidden = !hasChecklist;
  document.getElementById("questionsTabBtn").classList.toggle("sim-toggle__btn--active", contentType === "question");
  document.getElementById("redFlagsTabBtn").classList.toggle("sim-toggle__btn--active", contentType === "red_flag");
  document.getElementById("documentsTabBtn").classList.toggle("sim-toggle__btn--active", contentType === "checklist");
}

function setContentType(type) {
  contentType = type;
  startRound(currentCategory);
}

function setSimMode(on) {
  simMode = on;
  spokenMode = false;
  startRound("naturalization");
}

function setSpokenTest() {
  simMode = true;
  spokenMode = true;
  startRound("naturalization");
}

function setNatTestType(type) {
  natTestType = type;
  simMode = false;
  spokenMode = false;
  startRound("naturalization");
}

function setEnglishSection(section) {
  natEnglishSection = section;
  startRound("naturalization");
}

function startRound(category) {
  clearInterval(timerInterval);
  currentCategory = category;
  if (category !== "naturalization") { simMode = false; spokenMode = false; natTestType = "civics"; }
  if (!OPEN_FIELD.includes(category)) contentType = "question";
  updateNaturalizationUI();
  updateContentTypeToggle();

  let pool;
  if (category === "flagged") pool = allQuestions.filter(q => flaggedIds.has(q.id));
  else if (category === "naturalization") {
    const dbCategory = natTestType === "english" ? natEnglishSection : "naturalization";
    pool = allQuestions.filter(q => q.category === dbCategory);
  } else pool = allQuestions.filter(q => q.category === category && (q.content_type || "question") === contentType);

  quizSet = shuffle(pool);
  if (category === "naturalization" && natTestType === "civics" && simMode) quizSet = quizSet.slice(0, SIM_QUESTION_COUNT);
  simScore = { correct: 0, total: 0 };
  simTimes = [];
  currentIndex = 0;

  document.getElementById("quizDone").hidden = true;
  document.getElementById("quizCard").hidden = quizSet.length === 0;

  if (quizSet.length === 0) {
    renderDoneState(category === "flagged" ? "flaggedEmpty" : "finished");
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
  } else {
    badgeEl.hidden = true;
    textEl.hidden = false;
    textEl.textContent = DONE_MESSAGES[kind][currentLang];
    iconEl.className = "fa-solid fa-circle-check";
    iconEl.style.color = "";
    restartBtn.innerHTML = currentLang === "vi" ? translations.vi["btn.restart"] : '<i class="fa-solid fa-rotate-right"></i> Start Over';
    restartBtn.style.display = kind === "flaggedEmpty" ? "none" : "";
  }
}

function renderCurrentQuestion() {
  if (!quizSet.length || currentIndex >= quizSet.length) return;
  const q = quizSet[currentIndex];
  const ct = q.content_type || "question";

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
  if (ct !== "question") badge.textContent += currentLang === "vi" ? translations.vi["content.badge." + ct] : CONTENT_BADGE_SUFFIX_EN[ct];

  if (isSelfScored()) {
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
  questionEl.hidden = isWriting;
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
  if (spokenMode && simMode) enterSpokenAsk(q);
}

function renderActionButtons() {
  const selfScored = isSelfScored();
  const spoken = spokenMode && simMode;
  document.getElementById("quizSpoken").hidden = !spoken;
  document.getElementById("revealBtn").hidden = spoken;
  document.getElementById("nextBtn").hidden = selfScored || spoken;
  document.getElementById("gotItBtn").hidden = !selfScored || spoken;
  document.getElementById("missedBtn").hidden = !selfScored || spoken;
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

  if (!currentUser || !supabaseClient) return;
  try {
    if (nowFlagged) {
      await supabaseClient.from("flagged_questions")
        .upsert({ user_id: currentUser.id, question_id: q.id }, { onConflict: "user_id,question_id" });
    } else {
      await supabaseClient.from("flagged_questions")
        .delete().eq("user_id", currentUser.id).eq("question_id", q.id);
    }
  } catch (err) {
    console.error("Failed to sync flag:", err);
  }
}

function revealAnswer() {
  document.getElementById("quizAnswer").hidden = false;
  document.getElementById("quizQuestion").hidden = false;
  document.getElementById("quizWritingPrompt").hidden = true;
}

function nextQuestion() {
  currentIndex++;
  if (currentIndex >= quizSet.length) {
    let kind = "finished";
    if (simMode) kind = "simResult";
    else if (isSelfScored()) kind = "englishResult";
    if (kind === "simResult" || kind === "englishResult") {
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
  } else {
    renderCurrentQuestion();
  }
}

function recordSimAnswer(correct) {
  stopTimerAndRecord();
  simScore.total++;
  if (correct) simScore.correct++;
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
    startRound("marriage");
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

  document.getElementById("categories").addEventListener("click", (e) => {
    const btn = e.target.closest(".pill");
    if (!btn) return;
    document.querySelectorAll(".pill").forEach(p => p.classList.remove("pill--active"));
    btn.classList.add("pill--active");
    contentType = "question";
    startRound(btn.dataset.category);
  });

  document.getElementById("questionsTabBtn").addEventListener("click", () => setContentType("question"));
  document.getElementById("redFlagsTabBtn").addEventListener("click", () => setContentType("red_flag"));
  document.getElementById("documentsTabBtn").addEventListener("click", () => setContentType("checklist"));

  document.getElementById("revealBtn").addEventListener("click", revealAnswer);
  document.getElementById("nextBtn").addEventListener("click", nextQuestion);
  document.getElementById("restartBtn").addEventListener("click", () => startRound(currentCategory));
  document.getElementById("flagBtn").addEventListener("click", toggleFlagCurrentQuestion);
  document.getElementById("gotItBtn").addEventListener("click", () => recordSimAnswer(true));
  document.getElementById("missedBtn").addEventListener("click", () => recordSimAnswer(false));
  document.getElementById("practiceModeBtn").addEventListener("click", () => setSimMode(false));
  document.getElementById("simModeBtn").addEventListener("click", () => setSimMode(true));
  document.getElementById("spokenTestBtn").addEventListener("click", setSpokenTest);
  document.getElementById("micBtn").addEventListener("click", startListening);
  document.getElementById("repeatQuestionBtn").addEventListener("click", () => {
    const q = quizSet[currentIndex];
    if (q) speakText(q.question_en);
  });
  document.getElementById("spokenCorrectBtn").addEventListener("click", () => recordSimAnswer(true));
  document.getElementById("spokenWrongBtn").addEventListener("click", () => recordSimAnswer(false));
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
  document.getElementById("ctaLoginBtn").addEventListener("click", (e) => {
    e.stopPropagation();
    document.getElementById("accountPanel").hidden = false;
    const emailInput = document.getElementById("accountEmailInput");
    if (emailInput) emailInput.focus();
  });
  document.addEventListener("click", (e) => {
    const panel = document.getElementById("accountPanel");
    const btn = document.getElementById("accountBtn");
    if (!panel.hidden && !panel.contains(e.target) && !btn.contains(e.target)) panel.hidden = true;
  });
  document.getElementById("accountSendLinkBtn").addEventListener("click", () => {
    const email = document.getElementById("accountEmailInput").value.trim();
    const phone = document.getElementById("accountPhoneInput").value.trim();
    if (email) signInWithEmail(email, phone);
  });
  document.getElementById("accountEmailInput").addEventListener("keydown", (e) => {
    if (e.key === "Enter") document.getElementById("accountSendLinkBtn").click();
  });
  document.getElementById("accountPhoneInput").addEventListener("keydown", (e) => {
    if (e.key === "Enter") document.getElementById("accountSendLinkBtn").click();
  });
  document.getElementById("accountSavePhoneBtn").addEventListener("click", saveProfile);
  document.getElementById("accountPhoneInputLoggedIn").addEventListener("keydown", (e) => {
    if (e.key === "Enter") document.getElementById("accountSavePhoneBtn").click();
  });
  document.getElementById("accountLogoutBtn").addEventListener("click", signOutUser);

  populateStateSelect();
  loadStateOfficials();
  renderAccountUI();
  initAuth();
  loadQuestions();
});

// Register the service worker so the app is installable ("Add to Home Screen")
// and loads instantly on repeat visits. Data still comes live from Supabase.
if ("serviceWorker" in navigator) {
  window.addEventListener("load", () => {
    navigator.serviceWorker.register("sw.js").catch((err) => {
      console.warn("Service worker registration failed:", err);
    });
  });
}
