-- NASHVILLE HOUSING DATA CLEANING --

-- Standardize date format

select saledate,CONVERT(date,saledate)
from data 

update data
set saledate = CONVERT(date,saledate) -- SaleDate column is Not getting updated by this query hence tried below trick.
alter table data
add  SaleDateConverted date

update data
set saledateconverted = CONVERT(date,saledate)
-------------------------------------------------------------------------------------------------------------------
-- Populate Property Address data

select * from data
--where PropertyAddress is null
order by ParcelID --If parcel id is same then the PopertyAddress is also same


select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from data a
join data b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null 

update a
set propertyaddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from data a
join data b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null 

-------------------------------------------------------------------------------------------------------------------------------------
-- Breaking out address into individual column (Address,City,State)

select substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as city
from data -- Splitting address and city 

alter table data
add PropertySplitAddress nvarchar(255)

update data
set PropertySplitAddress =  substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table data
add PropertySplitCity nvarchar(255)

update data
set PropertySplitCity =  SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

--------

--OwnerAddress

select PARSENAME(REPLACE(owneraddress,',','.'),3) as address,
PARSENAME(REPLACE(owneraddress,',','.'),2) as city,
PARSENAME(REPLACE(owneraddress,',','.'),1) as state
from data

alter table data
add OwnerSplitAddress nvarchar(255)

alter table data
add OwnerSplitCity nvarchar(255)

alter table data
add OwnerSplitState nvarchar(255)

update data
set OwnerSplitAddress = PARSENAME(REPLACE(owneraddress,',','.'),3)

update data
set OwnerSplitCity = PARSENAME(REPLACE(owneraddress,',','.'),2)

update data
set OwnerSplitState = PARSENAME(REPLACE(owneraddress,',','.'),1)

------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in 'Sold as Vacant' table

select distinct(SoldAsVacant),COUNT(SoldAsVacant)
from data
group by SoldAsVacant
order by 2

select soldasvacant,
case when soldasvacant = 'Y' then 'Yes'
when soldasvacant = 'N' then 'No'
else soldasvacant
end
from data

update data
set SoldAsVacant = case when soldasvacant = 'Y' then 'Yes'
when soldasvacant = 'N' then 'No'
else soldasvacant
end
from data

---------------------------------------------------------------------------------------------------------------

--Removing duplicate records

with rownumcte as (
select *, 
dense_rank() over(
partition by parcelid,
             PropertyAddress,
			 SaleDate,
			 SalePrice,
			 LegalReference
			 order by uniqueid) row_num
from data)

delete  from rownumcte
where row_num >1

---------------------------------------------------------------------------------------------------------

-- Dropping unused columns

select * from data

alter table data
drop column PropertyAddress,SaleDate,OwnerAddress,TaxDistrict