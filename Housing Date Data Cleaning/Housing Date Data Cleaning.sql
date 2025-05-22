--Housing Date Data Clean
--1-Select the Data that will be cleaned:
select*from [Portfolio Project].dbo.Sheet1$
-----------------------------------------------------
--2-Standardize Date Format
select SaleDateConverted ,SaleDate
from [Portfolio Project].dbo.Sheet1$
select saleDateConverted, CONVERT(Date,SaleDate)
from [Portfolio Project].dbo.Sheet1$
ALTER TABLE [Portfolio Project].dbo.Sheet1$
Add SaleDateConverted Date;
Update [Portfolio Project].dbo.Sheet1$
Set saleDateConverted = CONVERT(Date,SaleDate)
-----------------------------------------------------------------
--3-Populate Property Address data
select *from [Portfolio Project].dbo.Sheet1$
Where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Portfolio Project].dbo.Sheet1$ a
JOIN [Portfolio Project].dbo.Sheet1$ b
	on a.ParcelID = b.ParcelID--=ParcelID are the same
	AND a.[UniqueID ] <> b.[UniqueID ]--=But UniquelID are not the same
Where a.PropertyAddress is null
Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Portfolio Project].dbo.Sheet1$ a
JOIN [Portfolio Project].dbo.Sheet1$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null
---------------------------------------------------------------------------------
--4-Breaking out Address into Individual Columns (Address, City, State)
select PropertyAddress
from [Portfolio Project].dbo.Sheet1$
--Where PropertyAddress is null
--order by ParcelID

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
from [Portfolio Project].dbo.Sheet1$

ALTER TABLE [Portfolio Project].dbo.Sheet1$
Add PropertySplitAddress Nvarchar(255);
Update [Portfolio Project].dbo.Sheet1$
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE [Portfolio Project].dbo.Sheet1$
Add PropertySplitCity Nvarchar(255);
Update [Portfolio Project].dbo.Sheet1$
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

select PropertyAddress,PropertySplitADdress,PropertySplitCity
from [Portfolio Project].dbo.Sheet1$

select OwnerAddress
from [Portfolio Project].dbo.Sheet1$

select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
from [Portfolio Project].dbo.Sheet1$

ALTER TABLE [Portfolio Project].dbo.Sheet1$
Add OwnerSplitAddress Nvarchar(255);
Update [Portfolio Project].dbo.Sheet1$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE [Portfolio Project].dbo.Sheet1$
Add OwnerSplitCity Nvarchar(255);
Update [Portfolio Project].dbo.Sheet1$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE [Portfolio Project].dbo.Sheet1$
Add OwnerSplitState Nvarchar(255);
Update [Portfolio Project].dbo.Sheet1$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

select OwnerAddress,OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
from [Portfolio Project].dbo.Sheet1$

----------------------------------------------------------------------------------------------
--5-Change Y and N to Yes and No in "Sold as Vacant" field

select Distinct(SoldAsVacant), Count(SoldAsVacant)
from [Portfolio Project].dbo.Sheet1$
Group by SoldAsVacant
order by 2

select SoldAsVacant,
  Case When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End
from [Portfolio Project].dbo.Sheet1$


Update [Portfolio Project].dbo.Sheet1$
SET SoldAsVacant = Case 
       When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End
-----------------------------------------------------------------------------------------------------------------------------------------------------------
--6-Remove Duplicates

with RowNumCTE as(
select *,
	ROW_NUMBER() Over ( --Using Partition by with keys that have unique data
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From [Portfolio Project].dbo.Sheet1$
--order by ParcelID
)
--Delete 
--From RowNumCTE
--Where row_num > 1
----Order by PropertyAddress

Select* 
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

Select *
From [Portfolio Project].dbo.Sheet1$
-----------------------------------------------------------------------------------------------
--7-Delete Unused Columns
Select *
From [Portfolio Project].dbo.Sheet1$

ALTER TABLE [Portfolio Project].dbo.Sheet1$
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
-----------------------------------------------------------------------------------------


