-- Storage policies for product images in the business-assets bucket.
-- Run this in Supabase SQL Editor for an existing project.

insert into storage.buckets(id,name,public)
values ('business-assets','business-assets',true)
on conflict (id) do update set public=true;

drop policy if exists "public can view business assets" on storage.objects;
create policy "public can view business assets"
on storage.objects
for select
to anon, authenticated
using (bucket_id = 'business-assets');

drop policy if exists "business owners can upload assets" on storage.objects;
create policy "business owners can upload assets"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'business-assets'
  and exists (
    select 1
    from public.businesses b
    where b.id = (storage.foldername(name))[1]::uuid
      and b.owner_id = auth.uid()
  )
);

drop policy if exists "business owners can update assets" on storage.objects;
create policy "business owners can update assets"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'business-assets'
  and exists (
    select 1
    from public.businesses b
    where b.id = (storage.foldername(name))[1]::uuid
      and b.owner_id = auth.uid()
  )
)
with check (
  bucket_id = 'business-assets'
  and exists (
    select 1
    from public.businesses b
    where b.id = (storage.foldername(name))[1]::uuid
      and b.owner_id = auth.uid()
  )
);

drop policy if exists "business owners can delete assets" on storage.objects;
create policy "business owners can delete assets"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'business-assets'
  and exists (
    select 1
    from public.businesses b
    where b.id = (storage.foldername(name))[1]::uuid
      and b.owner_id = auth.uid()
  )
);