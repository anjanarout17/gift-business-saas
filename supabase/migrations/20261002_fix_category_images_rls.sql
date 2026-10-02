-- Storage policies for product images in the business-assets bucket.
-- Run this in Supabase SQL Editor for an existing project.

insert into storage.buckets(id,name,public)
values ('business-assets','business-assets',true)
on conflict (id) do update set public=true;

-- Use a security-definer helper so Storage RLS does not depend on the
-- businesses table's own SELECT policy.
create or replace function public.is_business_owner(p_business_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.businesses
    where id = p_business_id
      and owner_id = auth.uid()
  );
$$;

revoke all on function public.is_business_owner(uuid) from public;
grant execute on function public.is_business_owner(uuid) to authenticated;

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
  and public.is_business_owner((storage.foldername(name))[1]::uuid)
);

drop policy if exists "business owners can update assets" on storage.objects;
create policy "business owners can update assets"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'business-assets'
  and public.is_business_owner((storage.foldername(name))[1]::uuid)
)
with check (
  bucket_id = 'business-assets'
  and public.is_business_owner((storage.foldername(name))[1]::uuid)
);

drop policy if exists "business owners can delete assets" on storage.objects;
create policy "business owners can delete assets"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'business-assets'
  and public.is_business_owner((storage.foldername(name))[1]::uuid)
);