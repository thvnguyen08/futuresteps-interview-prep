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
    "cat.marriage": "Thẻ Xanh Diện Hôn Nhân",
    "cat.naturalization": "Thi Quốc Tịch",
    "cat.asylum": "Phỏng Vấn Tị Nạn",
    "cat.f1": "Visa Du Học F-1",
    "cat.b1b2": "Visa Du Lịch/Công Tác B1/B2",
    "cat.flagged": "Đã Đánh Dấu",
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
    "footer.note": "Đây chỉ là tài liệu luyện tập, không phải tư vấn pháp lý. Để được hướng dẫn cụ thể cho trường hợp của bạn, hãy liên hệ trực tiếp với Future Steps Services.",
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

async function signInWithEmail(email) {
  const sentMsg = document.getElementById("accountSentMsg");
  const errorMsg = document.getElementById("accountErrorMsg");
  sentMsg.hidden = true;
  errorMsg.hidden = true;
  if (!supabaseClient) return;

  try {
    const { error } = await supabaseClient.auth.signInWithOtp({
      email,
      options: { emailRedirectTo: window.location.origin + window.location.pathname },
    });
    if (error) throw error;
    sentMsg.hidden = false;
  } catch (err) {
    console.error("Failed to send magic link:", err);
    errorMsg.textContent = currentLang === "vi" ? translations.vi["account.error"] : ACCOUNT_ERROR_EN;
    errorMsg.hidden = false;
  }
}

async function signOutUser() {
  if (!supabaseClient) return;
  await supabaseClient.auth.signOut();
  document.getElementById("accountPanel").hidden = true;
}

function renderAccountUI() {
  const btnLabel = document.getElementById("accountBtnLabel");
  const loggedOutEl = document.getElementById("accountLoggedOut");
  const loggedInEl = document.getElementById("accountLoggedIn");
  const emailDisplay = document.getElementById("accountEmailDisplay");

  if (currentUser) {
    btnLabel.textContent = currentUser.email;
    loggedOutEl.hidden = true;
    loggedInEl.hidden = false;
    emailDisplay.textContent = currentUser.email;
  } else {
    btnLabel.textContent = currentLang === "vi" ? translations.vi["account.login"] : "Log In";
    loggedOutEl.hidden = false;
    loggedInEl.hidden = true;
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
  document.getElementById("simModeBtn").classList.toggle("sim-toggle__btn--active", simMode);

  const showEnglishSub = isNat && natTestType === "english";
  document.getElementById("englishSectionToggle").hidden = !showEnglishSub;
  document.getElementById("speakingSectionBtn").classList.toggle("sim-toggle__btn--active", natEnglishSection === "eng_speaking");
  document.getElementById("readingSectionBtn").classList.toggle("sim-toggle__btn--active", natEnglishSection === "eng_reading");
  document.getElementById("writingSectionBtn").classList.toggle("sim-toggle__btn--active", natEnglishSection === "eng_writing");
}

function setSimMode(on) {
  simMode = on;
  startRound("naturalization");
}

function setNatTestType(type) {
  natTestType = type;
  simMode = false;
  startRound("naturalization");
}

function setEnglishSection(section) {
  natEnglishSection = section;
  startRound("naturalization");
}

function startRound(category) {
  clearInterval(timerInterval);
  currentCategory = category;
  if (category !== "naturalization") { simMode = false; natTestType = "civics"; }
  updateNaturalizationUI();

  let pool;
  if (category === "flagged") pool = allQuestions.filter(q => flaggedIds.has(q.id));
  else if (category === "naturalization") {
    const dbCategory = natTestType === "english" ? natEnglishSection : "naturalization";
    pool = allQuestions.filter(q => q.category === dbCategory);
  } else pool = allQuestions.filter(q => q.category === category);

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

  if (isSelfScored()) {
    const template = currentLang === "vi" ? translations.vi["sim.progress"] : SIM_PROGRESS_EN;
    progress.textContent = template
      .replace("{current}", currentIndex + 1)
      .replace("{total}", quizSet.length)
      .replace("{correct}", simScore.correct)
      .replace("{answered}", simScore.total);
  } else {
    const progressTemplate = currentLang === "vi" ? translations.vi["progress"] : "Question {current} of {total}";
    progress.textContent = progressTemplate
      .replace("{current}", currentIndex + 1)
      .replace("{total}", quizSet.length);
  }

  const isWriting = q.category === "eng_writing";
  questionEl.textContent = currentLang === "vi" ? q.question_vi : q.question_en;
  questionEl.hidden = isWriting;
  writingPromptEl.hidden = !isWriting;
  document.getElementById("quizTtsRow").hidden = !(isWriting && "speechSynthesis" in window);

  answerLabelEl.textContent = currentLang === "vi"
    ? translations.vi["answer.label." + q.category]
    : ANSWER_LABEL_EN[q.category];
  answerTextEl.textContent = currentLang === "vi" ? q.answer_vi : q.answer_en;

  answerBox.hidden = true;
  renderFlagButton();
  renderActionButtons();
  renderTimer();
}

function renderActionButtons() {
  const selfScored = isSelfScored();
  document.getElementById("nextBtn").hidden = selfScored;
  document.getElementById("gotItBtn").hidden = !selfScored;
  document.getElementById("missedBtn").hidden = !selfScored;
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
    startRound(btn.dataset.category);
  });

  document.getElementById("revealBtn").addEventListener("click", revealAnswer);
  document.getElementById("nextBtn").addEventListener("click", nextQuestion);
  document.getElementById("restartBtn").addEventListener("click", () => startRound(currentCategory));
  document.getElementById("flagBtn").addEventListener("click", toggleFlagCurrentQuestion);
  document.getElementById("gotItBtn").addEventListener("click", () => recordSimAnswer(true));
  document.getElementById("missedBtn").addEventListener("click", () => recordSimAnswer(false));
  document.getElementById("practiceModeBtn").addEventListener("click", () => setSimMode(false));
  document.getElementById("simModeBtn").addEventListener("click", () => setSimMode(true));
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
  document.getElementById("accountSendLinkBtn").addEventListener("click", () => {
    const email = document.getElementById("accountEmailInput").value.trim();
    if (email) signInWithEmail(email);
  });
  document.getElementById("accountEmailInput").addEventListener("keydown", (e) => {
    if (e.key === "Enter") document.getElementById("accountSendLinkBtn").click();
  });
  document.getElementById("accountLogoutBtn").addEventListener("click", signOutUser);

  renderAccountUI();
  initAuth();
  loadQuestions();
});
