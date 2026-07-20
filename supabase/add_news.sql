-- ═══════════════════════════════════════════════════════════════════
-- IMMIGRATION NEWS FEED
-- Run this once in the Supabase SQL editor. (Safe to re-run — it upgrades
-- the table in place and re-seeds the current stories.)
--
-- A small bilingual news table the app's home screen reads. Big stories can
-- be flagged `is_featured` (they get a breaking-news banner + a one-time
-- pop-up) and can carry `faqs` — practice Q&A officers may ask about that
-- change (e.g. the F-1 duration-of-status rule). Updated weekly by the
-- news-sync scheduled task via upsert_news_service() — data-only updates,
-- so fresh news never costs a Netlify deploy.
-- ═══════════════════════════════════════════════════════════════════

create table if not exists news (
  slot        int primary key check (slot between 1 and 6),
  tag_type    text not null default 'info' check (tag_type in ('alert', 'warning', 'info')),
  tag_en      text not null,
  tag_vi      text not null,
  title_en    text not null,
  title_vi    text not null,
  desc_en     text not null,
  desc_vi     text not null,
  news_date   date,
  source_name text,
  source_url  text,
  is_featured boolean not null default false,   -- big change → banner + pop-up
  category    text,                             -- most-affected service (marriage/f1/…), optional
  faqs        jsonb not null default '[]'::jsonb, -- [{q_en,q_vi,a_en,a_vi}, …] practice Q&A
  updated_at  timestamptz not null default now()
);

-- Upgrade older installs that predate the featured/category/faqs columns.
alter table news add column if not exists is_featured boolean not null default false;
alter table news add column if not exists category text;
alter table news add column if not exists faqs jsonb not null default '[]'::jsonb;

alter table news enable row level security;

-- Public content: anyone can read; nobody writes directly (no insert/update
-- policies) — writes go only through the secret-guarded RPC below.
drop policy if exists "news_public_read" on news;
create policy "news_public_read" on news for select using (true);
grant select on news to anon, authenticated;

-- Guarded write path for the weekly news-sync scheduled task (same shared
-- secret as get_crm_data_service in add_crm_service.sql). Items is a JSON
-- array of objects with the table's columns; rows upsert by slot.
create or replace function upsert_news_service(api_secret text, items jsonb)
returns void
language plpgsql
security definer
as $$
declare
  it jsonb;
begin
  if api_secret is null or api_secret != 'RYm1pAxn_SzSAeCh5w-9_Uz62X7NXfbwiSgGyEEL2Os' then
    return;
  end if;

  for it in select * from jsonb_array_elements(items) loop
    insert into news (slot, tag_type, tag_en, tag_vi, title_en, title_vi,
                      desc_en, desc_vi, news_date, source_name, source_url,
                      is_featured, category, faqs, updated_at)
    values (
      (it->>'slot')::int,
      coalesce(it->>'tag_type', 'info'),
      it->>'tag_en',  it->>'tag_vi',
      it->>'title_en', it->>'title_vi',
      it->>'desc_en',  it->>'desc_vi',
      (it->>'news_date')::date,
      it->>'source_name', it->>'source_url',
      coalesce((it->>'is_featured')::boolean, false),
      it->>'category',
      coalesce(it->'faqs', '[]'::jsonb),
      now()
    )
    on conflict (slot) do update set
      tag_type    = excluded.tag_type,
      tag_en      = excluded.tag_en,
      tag_vi      = excluded.tag_vi,
      title_en    = excluded.title_en,
      title_vi    = excluded.title_vi,
      desc_en     = excluded.desc_en,
      desc_vi     = excluded.desc_vi,
      news_date   = excluded.news_date,
      source_name = excluded.source_name,
      source_url  = excluded.source_url,
      is_featured = excluded.is_featured,
      category    = excluded.category,
      faqs        = excluded.faqs,
      updated_at  = now();
  end loop;
end;
$$;

grant execute on function upsert_news_service(text, jsonb) to anon;

-- ── Seed: the website's current three stories (2026-07-20 refresh), with
--    practice Q&A on the two interview-relevant rule changes ──

insert into news (slot, tag_type, tag_en, tag_vi, title_en, title_vi, desc_en, desc_vi, news_date, source_name, source_url, is_featured, category, faqs)
values
(1, 'alert', 'Policy Update', 'Cập Nhật Chính Sách',
 'DHS Rescinds 2022 Public Charge Rule, Giving USCIS Officers Broader Discretion on Green Card Cases',
 'DHS Bãi Bỏ Quy Định "Gánh Nặng Xã Hội" (Public Charge) Năm 2022, Trao Quyền Quyết Định Rộng Hơn Cho Viên Chức USCIS',
 'DHS published a final rule on July 20, 2026 rescinding the Biden-era 2022 public charge regulation, striking the prior definitions and determination framework entirely rather than replacing them with a new rule. Effective September 18, 2026, USCIS officers will assess an applicant self-sufficiency using broader case-by-case discretion, and a revised Form I-485 will be required for green card applications filed on or after that date.',
 'Bộ An Ninh Nội Địa Hoa Kỳ (DHS) đã ban hành quy định chính thức vào ngày 20/7/2026, bãi bỏ hoàn toàn quy định "gánh nặng xã hội" (public charge) từ thời chính quyền Biden năm 2022 — xóa bỏ các định nghĩa và khung xét duyệt trước đó thay vì thay thế bằng quy định mới. Có hiệu lực từ ngày 18/9/2026, viên chức USCIS sẽ được toàn quyền xem xét khả năng tự lập tài chính của đương đơn theo từng trường hợp cụ thể, và mẫu đơn I-485 phiên bản mới sẽ bắt buộc áp dụng cho các hồ sơ xin thẻ xanh nộp từ ngày đó trở đi.',
 '2026-07-20', 'USCIS.gov',
 'https://www.uscis.gov/newsroom/news-releases/us-citizenship-and-immigration-services-rescinds-2022-public-charge-regulation',
 false, 'marriage',
 '[
   {"q_en":"How will USCIS decide whether you might become a public charge?","a_en":"From September 18, 2026, officers weigh your overall self-sufficiency case-by-case — age, health, income, assets, education, and the Affidavit of Support from your sponsor. Be ready to show that you and your sponsor can support your household without relying on public benefits.","q_vi":"USCIS sẽ quyết định như thế nào về việc bạn có thể trở thành gánh nặng xã hội hay không?","a_vi":"Từ ngày 18/9/2026, viên chức sẽ xem xét tổng thể khả năng tự lập của bạn theo từng trường hợp — tuổi tác, sức khỏe, thu nhập, tài sản, học vấn và Bản Cam Kết Bảo Trợ Tài Chính từ người bảo lãnh. Hãy sẵn sàng chứng minh rằng bạn và người bảo lãnh có thể chu cấp cho gia đình mà không cần trợ cấp công."},
   {"q_en":"Which form is now required for a green card application?","a_en":"A revised Form I-485 is required for green card applications filed on or after September 18, 2026. Always download the current edition from USCIS.gov before you file.","q_vi":"Mẫu đơn nào hiện bắt buộc cho hồ sơ xin thẻ xanh?","a_vi":"Mẫu I-485 phiên bản mới bắt buộc áp dụng cho hồ sơ xin thẻ xanh nộp từ ngày 18/9/2026 trở đi. Hãy luôn tải phiên bản hiện hành từ USCIS.gov trước khi nộp."}
 ]'::jsonb),
(2, 'warning', 'Student Visa Alert', 'Cảnh Báo Visa Du Học',
 'DHS Ends "Duration of Status" for F-1 Students — Fixed Admission Periods Start September 15',
 'DHS Chấm Dứt Chế Độ "Lưu Trú Không Xác Định Thời Hạn" Cho Du Học Sinh F-1 — Áp Dụng Thời Hạn Cố Định Từ 15/9',
 'A DHS final rule published July 17, 2026 in the Federal Register eliminates open-ended "duration of status" for F academic students (plus J exchange visitors and I media representatives), admitting them instead for a fixed period tied to their program length — capped at four years, plus 30-day grace periods for arrival and departure. Students needing more time must file a formal Extension of Stay directly with USCIS, including biometrics and background checks, shifting oversight away from school staff. The rule takes effect September 15, 2026.',
 'Quy định chính thức của DHS được công bố ngày 17/7/2026 trên Federal Register đã xóa bỏ chế độ "duration of status" (lưu trú không xác định thời hạn) đối với du học sinh diện F, khách trao đổi diện J và đại diện truyền thông diện I. Thay vào đó, đương đơn sẽ được cấp thời hạn nhập cảnh cố định theo thời lượng chương trình học — tối đa 4 năm, cộng thêm 30 ngày trước và sau khóa học. Sinh viên cần thêm thời gian phải nộp đơn xin gia hạn (Extension of Stay) trực tiếp với USCIS, bao gồm lấy sinh trắc học và kiểm tra lý lịch, thay vì do nhà trường quản lý như trước. Quy định có hiệu lực từ ngày 15/9/2026.',
 '2026-07-17', 'DHS.gov',
 'https://www.dhs.gov/news/2026/07/16/trump-administration-issues-final-rule-end-foreign-student-visa-abuse',
 true, 'f1',
 '[
   {"q_en":"I''m already in the US on D/S — does my I-94 change on September 15, 2026?","a_en":"If you are properly maintaining status on September 15, 2026, your I-94 generally will not be corrected right away — your D/S admission gets a \"transition end date\" instead. You do not need to act immediately, but you should know your new outside deadline.","q_vi":"Tôi đã ở Mỹ theo diện D/S — mẫu I-94 của tôi có thay đổi vào ngày 15/9/2026 không?","a_vi":"Nếu bạn đang duy trì tình trạng hợp lệ vào ngày 15/9/2026, mẫu I-94 của bạn thường sẽ không bị điều chỉnh ngay — thay vào đó, việc nhập cảnh diện D/S của bạn sẽ có một \"ngày kết thúc chuyển tiếp\". Bạn không cần làm gì ngay, nhưng nên nắm rõ thời hạn cuối cùng mới của mình."},
   {"q_en":"How long can I stay if I was admitted under D/S before the rule?","a_en":"You may stay until the later of your EAD expiration (if any) or the program end date on your valid Form I-20 — but not beyond four years from September 15, 2026, plus a 60-day departure period (an outside deadline around November 14, 2030). After that you must extend or depart.","q_vi":"Nếu tôi được nhập cảnh diện D/S trước khi có quy định, tôi được ở lại bao lâu?","a_vi":"Bạn được ở lại đến thời điểm muộn hơn giữa: ngày hết hạn Giấy Phép Lao Động (EAD, nếu có) hoặc ngày kết thúc chương trình trên mẫu I-20 còn hiệu lực — nhưng không quá 4 năm kể từ 15/9/2026, cộng thêm 60 ngày để rời đi (hạn chót vào khoảng 14/11/2030). Sau đó bạn phải gia hạn hoặc rời khỏi Hoa Kỳ."},
   {"q_en":"Can I transfer to a new school under the new rule?","a_en":"Transfers are much more limited now. Undergraduates generally cannot transfer during their first academic year, and graduate students generally cannot transfer at all once enrolled. Exceptions require SEVP approval for extenuating circumstances.","q_vi":"Tôi có thể chuyển sang trường mới theo quy định mới không?","a_vi":"Việc chuyển trường giờ đây bị hạn chế nhiều hơn. Sinh viên đại học thường không được chuyển trường trong năm học đầu tiên, và học viên sau đại học thường hoàn toàn không được chuyển trường sau khi đã nhập học. Các trường hợp ngoại lệ cần được SEVP chấp thuận vì lý do bất khả kháng."},
   {"q_en":"I''m a graduate student — can I still transfer schools?","a_en":"Graduate students are generally barred from transferring to a new institution once enrolled, unless SEVP authorizes an exception for extenuating circumstances. Talk to your DSO — and ideally an attorney — before assuming a transfer is possible.","q_vi":"Tôi là học viên sau đại học — tôi còn chuyển trường được không?","a_vi":"Học viên sau đại học thường bị cấm chuyển sang trường mới sau khi đã nhập học, trừ khi SEVP cho phép ngoại lệ vì lý do bất khả kháng. Hãy trao đổi với cố vấn nhà trường (DSO) — và tốt nhất là luật sư — trước khi cho rằng bạn có thể chuyển trường."},
   {"q_en":"If I transfer schools, will my new school''s DSO update my I-94 admit-until date?","a_en":"No — this is a costly misunderstanding to avoid. When you transfer, your DSO updates your SEVIS record and issues a new Form I-20, but that does not change your Form I-94 \"admit until\" date. Only CBP (when you re-enter the US) or a USCIS-approved I-539 extension can change that date, so if your transfer needs more time than your I-94 allows, you must file an I-539 or depart and re-enter — never assume the new I-20 or SEVIS update extends your stay.","q_vi":"Nếu tôi chuyển trường, cố vấn (DSO) của trường mới có cập nhật ngày kết thúc lưu trú trên I-94 của tôi không?","a_vi":"Không — đây là hiểu lầm nguy hiểm cần tránh. Khi bạn chuyển trường, cố vấn nhà trường (DSO) cập nhật hồ sơ SEVIS và cấp mẫu I-20 mới, nhưng điều đó KHÔNG thay đổi ngày kết thúc lưu trú (\"admit until\") trên mẫu I-94 của bạn. Chỉ có CBP (khi bạn nhập cảnh lại Hoa Kỳ) hoặc đơn I-539 được USCIS chấp thuận mới thay đổi được ngày đó. Vì vậy, nếu việc chuyển trường cần thêm thời gian vượt quá hạn I-94, bạn phải nộp I-539 hoặc rời đi rồi nhập cảnh lại — đừng bao giờ cho rằng I-20 mới hay việc cập nhật SEVIS sẽ tự động gia hạn thời gian lưu trú của bạn."},
   {"q_en":"What happens to my I-94 if I travel abroad after September 15, 2026?","a_en":"If you leave the US and re-enter after September 15, 2026, CBP will admit you with a fixed I-94 \"admit until\" date under the new framework (no longer D/S). Carry an updated, properly signed Form I-20 and check your new I-94 date after each entry.","q_vi":"Nếu tôi đi nước ngoài sau ngày 15/9/2026, mẫu I-94 của tôi sẽ ra sao?","a_vi":"Nếu bạn rời Hoa Kỳ và nhập cảnh lại sau ngày 15/9/2026, CBP sẽ cho bạn nhập cảnh với ngày kết thúc lưu trú cố định trên mẫu I-94 theo quy định mới (không còn D/S). Hãy mang theo mẫu I-20 đã cập nhật và có chữ ký hợp lệ, và kiểm tra ngày I-94 mới sau mỗi lần nhập cảnh."},
   {"q_en":"How do I extend my stay if I need more time to finish?","a_en":"File Form I-539 with USCIS — with the fee (about $420 online / $470 paper as of July 2026) and biometrics — before your I-94 \"admit until\" date. Request the extension through your DSO first if required, and file early.","q_vi":"Làm sao để gia hạn lưu trú nếu tôi cần thêm thời gian học?","a_vi":"Nộp mẫu I-539 cho USCIS — kèm lệ phí (khoảng $420 nộp trực tuyến / $470 nộp giấy tính đến tháng 7/2026) và lấy sinh trắc học — trước ngày kết thúc lưu trú trên I-94. Nếu cần, hãy xin gia hạn qua cố vấn nhà trường (DSO) trước, và nộp sớm."},
   {"q_en":"Do I need to file an extension of stay for OPT or STEM OPT?","a_en":"If you file Form I-765 for OPT or STEM OPT on or before March 18, 2027, you generally do not need a separate Extension of Stay for that period. File after that date and you may need both the I-765 and an I-539 if your I-94 period will not cover the work.","q_vi":"Tôi có phải nộp đơn gia hạn lưu trú cho OPT hoặc STEM OPT không?","a_vi":"Nếu bạn nộp mẫu I-765 để xin OPT hoặc STEM OPT vào hoặc trước ngày 18/3/2027, thường bạn không cần nộp đơn gia hạn lưu trú riêng cho giai đoạn đó. Nếu nộp sau ngày đó, bạn có thể phải nộp cả mẫu I-765 lẫn I-539 nếu thời hạn I-94 không bao phủ thời gian làm việc."},
   {"q_en":"How long is my grace period after I finish my program now?","a_en":"The post-completion grace period is cut from 60 to 30 days — you have 30 days after finishing your program (or authorized practical training) to depart, transfer, or change status. Students who fall out of status get no grace period and must leave immediately.","q_vi":"Sau khi hoàn thành chương trình, thời gian ân hạn của tôi là bao lâu?","a_vi":"Thời gian ân hạn sau khi hoàn thành chương trình bị rút từ 60 xuống còn 30 ngày — bạn có 30 ngày sau khi kết thúc chương trình học (hoặc thực tập được cấp phép) để rời đi, chuyển trường hoặc chuyển đổi tình trạng. Sinh viên bị mất tình trạng hợp lệ không có thời gian ân hạn và phải rời đi ngay lập tức."},
   {"q_en":"What happens if I miss my I-94 \"admit-until\" date?","a_en":"If your I-94 \"admit until\" date passes and you have not filed an extension, departed, or otherwise maintained status, you begin accruing unlawful presence — which can trigger 3-year or 10-year bars on returning to the US. Track your date closely.","q_vi":"Điều gì xảy ra nếu tôi để quá ngày kết thúc lưu trú trên I-94?","a_vi":"Nếu ngày kết thúc lưu trú trên I-94 đã qua mà bạn chưa nộp đơn gia hạn, chưa rời đi, hoặc không duy trì tình trạng hợp lệ, bạn sẽ bắt đầu tích lũy thời gian cư trú bất hợp pháp — điều này có thể dẫn đến lệnh cấm nhập cảnh 3 năm hoặc 10 năm. Hãy theo dõi sát ngày của bạn."},
   {"q_en":"How is \"unlawful presence\" different under the new rule?","a_en":"Under the old D/S system, unlawful presence usually started only after a formal finding by USCIS or an immigration judge. Now it starts automatically the day after your I-94 \"admit until\" date if you have not extended or departed — so tracking that date is critical to avoid the 3-year and 10-year re-entry bars.","q_vi":"Khái niệm \"cư trú bất hợp pháp\" khác thế nào theo quy định mới?","a_vi":"Theo chế độ D/S cũ, thời gian cư trú bất hợp pháp thường chỉ bắt đầu sau khi USCIS hoặc thẩm phán di trú ra phán quyết chính thức. Giờ đây, nó bắt đầu tự động ngay ngày hôm sau ngày kết thúc lưu trú trên I-94 nếu bạn chưa gia hạn hoặc chưa rời đi — vì vậy việc theo dõi ngày đó là rất quan trọng để tránh lệnh cấm nhập cảnh 3 năm và 10 năm."}
 ]'::jsonb),
(3, 'info', 'Work Visa Update', 'Cập Nhật Visa Lao Động',
 'USCIS Confirms FY 2027 H-1B Cap Reached — No Second Lottery',
 'USCIS Xác Nhận Đã Đủ Chỉ Tiêu H-1B Năm Tài Khóa 2027 — Không Tổ Chức Bốc Thăm Vòng Hai',
 'USCIS announced on July 17, 2026 that it received enough petitions to fill both the 65,000 regular H-1B cap and the 20,000 U.S. advanced-degree exemption for fiscal year 2027, and will not hold an additional selection round. It is the first cycle run under the new wage-weighted selection system, and USCIS reports nearly 72% of selected beneficiaries held a U.S. advanced degree, up from 57% in the previous cycle.',
 'USCIS thông báo ngày 17/7/2026 rằng cơ quan đã nhận đủ hồ sơ để lấp đầy cả hạn ngạch H-1B thường niên 65.000 suất và diện miễn trừ bằng thạc sĩ Hoa Kỳ 20.000 suất cho năm tài khóa 2027, và sẽ không tổ chức thêm vòng bốc thăm bổ sung. Đây là chu kỳ đầu tiên áp dụng hệ thống chọn lọc theo mức lương mới của DHS, với gần 72% người được chọn có bằng thạc sĩ Hoa Kỳ trở lên, tăng so với 57% ở chu kỳ trước.',
 '2026-07-17', 'USCIS.gov',
 'https://www.uscis.gov/newsroom/alerts/uscis-reaches-fiscal-year-2027-h-1b-cap',
 false, null, '[]'::jsonb)
on conflict (slot) do update set
  tag_type    = excluded.tag_type,
  tag_en      = excluded.tag_en,
  tag_vi      = excluded.tag_vi,
  title_en    = excluded.title_en,
  title_vi    = excluded.title_vi,
  desc_en     = excluded.desc_en,
  desc_vi     = excluded.desc_vi,
  news_date   = excluded.news_date,
  source_name = excluded.source_name,
  source_url  = excluded.source_url,
  is_featured = excluded.is_featured,
  category    = excluded.category,
  faqs        = excluded.faqs,
  updated_at  = now();
