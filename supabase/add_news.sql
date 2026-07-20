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
   {"q_en":"How long are you now admitted to stay in the United States?","a_en":"Under the new rule (effective September 15, 2026) F-1 students are admitted for a fixed period tied to your program length — up to a maximum of four years — plus a 30-day grace period, instead of the old open-ended \"duration of status.\" Know your exact admit-until date.","q_vi":"Bây giờ bạn được phép ở lại Hoa Kỳ trong bao lâu?","a_vi":"Theo quy định mới (có hiệu lực từ 15/9/2026), du học sinh F-1 được cấp thời hạn cố định theo thời lượng chương trình học — tối đa 4 năm — cộng thêm 30 ngày ân hạn, thay cho chế độ \"lưu trú không xác định thời hạn\" trước đây. Hãy nắm rõ ngày kết thúc lưu trú chính xác của bạn."},
   {"q_en":"What must you do if you need more time to finish your program?","a_en":"You must file a formal Extension of Stay (Form I-539) directly with USCIS before your admission period ends, including biometrics and a background check. Do not let your authorized stay lapse — apply well in advance.","q_vi":"Bạn phải làm gì nếu cần thêm thời gian để hoàn thành chương trình học?","a_vi":"Bạn phải nộp đơn xin gia hạn lưu trú (Mẫu I-539) trực tiếp với USCIS trước khi thời hạn nhập cảnh kết thúc, bao gồm lấy sinh trắc học và kiểm tra lý lịch. Đừng để thời gian lưu trú hợp pháp bị hết hạn — hãy nộp đơn sớm."},
   {"q_en":"Who now controls how long you can stay — your school or USCIS?","a_en":"USCIS now controls your period of stay through fixed admission dates, shifting oversight away from the school (DSO). Track your own Form I-94 admit-until date and do not rely on your school to extend it automatically.","q_vi":"Ai kiểm soát thời gian bạn được ở lại — nhà trường hay USCIS?","a_vi":"USCIS hiện kiểm soát thời gian lưu trú của bạn qua ngày nhập cảnh cố định, thay vì do nhà trường (DSO) quản lý. Hãy tự theo dõi ngày kết thúc lưu trú trên Mẫu I-94 và đừng trông chờ nhà trường tự động gia hạn."},
   {"q_en":"When does this rule take effect?","a_en":"September 15, 2026. Admissions and extensions on or after that date follow the new fixed-period system.","q_vi":"Quy định này có hiệu lực khi nào?","a_vi":"Ngày 15/9/2026. Việc nhập cảnh và gia hạn từ ngày đó trở đi sẽ áp dụng theo hệ thống thời hạn cố định mới."}
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
