-- checking the data 

select * 
from Nashville
order by 1

--Standardize Sale Date 

--select saledate, CONVERT(date,saledate)
--from Nashville

--update Nashville
--set SaleDate = CONVERT(date,saledate)

alter table nashville
alter column saledate date 

-- Populate Property Address data

select *
from nashville
where propertyaddress is null
order by parcelid

select nash.ParcelID,nash.PropertyAddress,bash.ParcelID,bash.PropertyAddress, ISNULL(nash.propertyaddress,bash.PropertyAddress)
from nashville nash
join Nashville bash
on nash.ParcelID = bash.ParcelID
and nash.[UniqueID ]<>bash.[UniqueID ]
where nash.PropertyAddress is null

update nash 
set propertyaddress = ISNULL(nash.propertyaddress,bash.PropertyAddress)
from nashville nash
join Nashville bash
on nash.ParcelID = bash.ParcelID
and nash.[UniqueID ]<>bash.[UniqueID ]
where nash.PropertyAddress is null

-- Checking the populaied data

select propertyaddress,uniqueid 
from Nashville
where propertyaddress is null

-- Breaking the address into coloumns 

select propertyaddress
from Nashville

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as address
, SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(propertyaddress)) as address1
from nashville 

Alter table nashville
Add Addressline1 nvarchar(255)
update Nashville
set addressline1 = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)

Alter table nashville
Add City varchar(255)
update Nashville
set city = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(propertyaddress))

select propertyaddress,addressline1,city
from Nashville
  
-- Splitting without using sub string on owner address

  select owneraddress
  from nashville
   
 select 
 PARSENAME(replace(owneraddress,',','.'),3)
 ,PARSENAME(replace(owneraddress,',','.'),2)
 ,PARSENAME(replace(owneraddress,',','.'),1)
 from Nashville

 alter table nashville
 add OwnerAddress1 nvarchar(255)
 update Nashville
 set OwnerAddress1 = PARSENAME(replace(owneraddress,',','.'),3)

 alter table nashville
 add OwnerCity nvarchar(255)
 update Nashville
 set OwnerCity = PARSENAME(replace(owneraddress,',','.'),2)

 alter table nashville
 add OwnerState nvarchar(255)
 update Nashville
 set OwnerState = PARSENAME(replace(owneraddress,',','.'),1)

 select owneraddress,owneraddress1,ownercity,ownerstate
 from Nashville

 -- Change Y and N to yes and no in "sold as vacant" field 

 select distinct(soldasvacant),count(soldasvacant)
 from Nashville
 group by soldasvacant
 order by 2

 select soldasvacant ,
 case when soldasvacant = 'Y' then 'Yes'
      when soldasvacant = 'N' then 'No' 
	  else soldasvacant
	  end 
from Nashville

update Nashville
set soldasvacant =  case when soldasvacant = 'Y' then 'Yes'
      when soldasvacant = 'N' then 'No' 
	  else soldasvacant
	  end 

-- remove duplicates 

With ROWNUMCTE as (
select * ,
      Row_Number() over (
	   partition by parcelid,
	                propertyaddress,
					saleprice,
					saledate,
					legalreference
					order by uniqueid) row_num
					
from nashville )
select *
 from ROWNUMCTE
 where row_num>1


