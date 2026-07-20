-- ═══════════════════════════════════════════════════════════════════
-- IMMIGRATION NEWS FEED
-- Run this once in the Supabase SQL editor.
--
-- A small bilingual news table the app's home screen reads (3 slots,
-- matching the website's "Latest Immigration News" section). Updated
-- weekly by the news-sync scheduled task via upsert_news_service()
-- — data-only updates, so fresh news never costs a Netlify deploy.
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
  updated_at  timestamptz not null default now()
);

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
                      desc_en, desc_vi, news_date, source_name, source_url, updated_at)
    values (
      (it->>'slot')::int,
      coalesce(it->>'tag_type', 'info'),
      it->>'tag_en',  it->>'tag_vi',
      it->>'title_en', it->>'title_vi',
      it->>'desc_en',  it->>'desc_vi',
      (it->>'news_date')::date,
      it->>'source_name', it->>'source_url',
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
      updated_at  = now();
  end loop;
end;
$$;

grant execute on function upsert_news_service(text, jsonb) to anon;

-- ── Seed: the website's current three stories (2026-07-20 refresh) ──

insert into news (slot, tag_type, tag_en, tag_vi, title_en, title_vi, desc_en, desc_vi, news_date, source_name, source_url)
values
(1, 'alert', 'Policy Update', 'Cập Nhật Chính Sách',
 'DHS Rescinds 2022 Public Charge Rule, Giving USCIS Officers Broader Discretion on Green Card Cases',
 'DHS Bãi Bỏ Quy Định "Gánh Nặng Xã Hội" (Public Charge) Năm 2022, Trao Quyền Quyết Định Rộng Hơn Cho Viên Chức USCIS',
 'DHS published a final rule on July 20, 2026 rescinding the Biden-era 2022 public charge regulation, striking the prior definitions and determination framework entirely rather than replacing them with a new rule. Effective September 18, 2026, USCIS officers will assess an applicant''s self-sufficiency using broader case-by-case discretion, and a revised Form I-485 will be required for green card applications filed on or after that date.',
 'Bộ An Ninh Nội Địa Hoa Kỳ (DHS) đã ban hành quy định chính thức vào ngày 20/7/2026, bãi bỏ hoàn toàn quy định "gánh nặng xã hội" (public charge) từ thời chính quyền Biden năm 2022 — xóa bỏ các định nghĩa và khung xét duyệt trước đó thay vì thay thế bằng quy định mới. Có hiệu lực từ ngày 18/9/2026, viên chức USCIS sẽ được toàn quyền xem xét khả năng tự lập tài chính của đương đơn theo từng trường hợp cụ thể, và mẫu đơn I-485 phiên bản mới sẽ bắt buộc áp dụng cho các hồ sơ xin thẻ xanh nộp từ ngày đó trở đi.',
 '2026-07-20', 'USCIS.gov',
 'https://www.uscis.gov/newsroom/news-releases/us-citizenship-and-immigration-services-rescinds-2022-public-charge-regulation'),
(2, 'warning', 'Student Visa Alert', 'Cảnh Báo Visa Du Học',
 'DHS Ends "Duration of Status" for F-1 Students — Fixed Admission Periods Start September 15',
 'DHS Chấm Dứt Chế Độ "Lưu Trú Không Xác Định Thời Hạn" Cho Du Học Sinh F-1 — Áp Dụng Thời Hạn Cố Định Từ 15/9',
 'A DHS final rule published July 17, 2026 in the Federal Register eliminates open-ended "duration of status" for F academic students (plus J exchange visitors and I media representatives), admitting them instead for a fixed period tied to their program length — capped at four years, plus 30-day grace periods for arrival and departure. Students needing more time must file a formal Extension of Stay directly with USCIS, including biometrics and background checks, shifting oversight away from school staff. The rule takes effect September 15, 2026.',
 'Quy định chính thức của DHS được công bố ngày 17/7/2026 trên Federal Register đã xóa bỏ chế độ "duration of status" (lưu trú không xác định thời hạn) đối với du học sinh diện F, khách trao đổi diện J và đại diện truyền thông diện I. Thay vào đó, đương đơn sẽ được cấp thời hạn nhập cảnh cố định theo thời lượng chương trình học — tối đa 4 năm, cộng thêm 30 ngày trước và sau khóa học. Sinh viên cần thêm thời gian phải nộp đơn xin gia hạn (Extension of Stay) trực tiếp với USCIS, bao gồm lấy sinh trắc học và kiểm tra lý lịch, thay vì do nhà trường quản lý như trước. Quy định có hiệu lực từ ngày 15/9/2026.',
 '2026-07-17', 'DHS.gov',
 'https://www.dhs.gov/news/2026/07/16/trump-administration-issues-final-rule-end-foreign-student-visa-abuse'),
(3, 'info', 'Work Visa Update', 'Cập Nhật Visa Lao Động',
 'USCIS Confirms FY 2027 H-1B Cap Reached — No Second Lottery',
 'USCIS Xác Nhận Đã Đủ Chỉ Tiêu H-1B Năm Tài Khóa 2027 — Không Tổ Chức Bốc Thăm Vòng Hai',
 'USCIS announced on July 17, 2026 that it received enough petitions to fill both the 65,000 regular H-1B cap and the 20,000 U.S. advanced-degree exemption for fiscal year 2027, and will not hold an additional selection round. It''s the first cycle run under DHS''s new wage-weighted selection system, and USCIS reports nearly 72% of selected beneficiaries held a U.S. advanced degree, up from 57% in the previous cycle.',
 'USCIS thông báo ngày 17/7/2026 rằng cơ quan đã nhận đủ hồ sơ để lấp đầy cả hạn ngạch H-1B thường niên 65.000 suất và diện miễn trừ bằng thạc sĩ Hoa Kỳ 20.000 suất cho năm tài khóa 2027, và sẽ không tổ chức thêm vòng bốc thăm bổ sung. Đây là chu kỳ đầu tiên áp dụng hệ thống chọn lọc theo mức lương mới của DHS, với gần 72% người được chọn có bằng thạc sĩ Hoa Kỳ trở lên, tăng so với 57% ở chu kỳ trước.',
 '2026-07-17', 'USCIS.gov',
 'https://www.uscis.gov/newsroom/alerts/uscis-reaches-fiscal-year-2027-h-1b-cap')
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
  updated_at  = now();
