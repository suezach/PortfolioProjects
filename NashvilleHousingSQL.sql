/* Cleaning Data in SQL Queries */
--------------------------------------------------------------------------------------------------------------------------------
Select *
from PortfolioProject..NashvilleHousing


--Standardize Date Format

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDateConverted
From PortfolioProject..NashvilleHousing

---------------------------------------------------------------------------------------------------------------------------------

--Populate Property Address Field

Select *
From PortfolioProject..NashvilleHousing
where PropertyAddress is null


Select *
from PortfolioProject..NashvilleHousing
Order by ParcelID


-- In order to populate missing values for PropertyAddress, we can find the ParcelID similar to the ParcelId of missing PropertyAddress and populate the field
-- perform a self join
-- To populate the propertyaddress with the new column data
Update H1
set PropertyAddress = isnull(H1.PropertyAddress, H2.PropertyAddress)
From PortfolioProject..NashvilleHousing H1,PortfolioProject..NashvilleHousing H2 
where H1.ParcelID = H2.ParcelID
and H1.[UniqueID ] <> H2.[UniqueID ]
and H1.PropertyAddress is null

-- Check the table 
Select * 
from PortfolioProject..NashvilleHousing
where PropertyAddress is null 
--Above query returns NO null values. We have successfully poplulated the missing values for the Property Address column

---------------------------------------------------------------------------------------------------------------------------------

--Breaking out PropertyAddress into Individual Column(Address, City, State)


Select 
Substring( PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 ) As Address,
Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) As City
from PortfolioProject..NashvilleHousing

--- Another way of spliting the address is by using the Alter table and Update

Alter Table NashvilleHousing
Add PropertysplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertysplitAddress = Substring( PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 )

Alter Table NashvilleHousing
Add PropertysplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertysplitCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))

Select * 
From PortfolioProject..NashvilleHousing


--Spliting the Owner Address into address, City and State
--Using PARSENAME
select OwnerAddress
from PortfolioProject..NashvilleHousing

select 
PARSENAME(Replace(OwnerAddress, ',', '.'), 3) -- parsename uses delimiter '.' by default, so we use REPLACE to replace the ',' with '.'
,PARSENAME(Replace(OwnerAddress, ',', '.'), 2)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
from
PortfolioProject..NashvilleHousing

-- Use alter table and update 

Alter Table PortfolioProject..NashvilleHousing
Add OwnersplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnersplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3) 

Alter Table PortfolioProject..NashvilleHousing
Add OwnersplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnersplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2) 

Alter Table PortfolioProject..NashvilleHousing
Add OwnersplitState Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnersplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)


---------------------------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in 'Sold as Vacant' field

select distinct(SoldAsVacant), count(SoldAsvacant) 
from PortfolioProject..NashvilleHousing  -- There are rows with 'N' and 'Y' , which need to be replaced by 'No' and 'Yes'
Group By SoldAsVacant
order by 2
-- the output shows 52 rows with 'Y' and 399 rows with 'N' which need to be changed to 'No' and 'Yes'

-- CASE statement

select SoldAsVacant 
, CASE when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   ELSE SoldAsVacant
	   END
from PortfolioProject..NashvilleHousing

-- Now we update the table
Update PortfolioProject..NashvilleHousing
Set SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   ELSE SoldAsVacant
	   END

--------------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates, we write a CTE 
WITH RowNumCTE AS(
select *,
    ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by UniqueID
				) row_num
from PortfolioProject.dbo.NashvilleHousing
)
select * 
from RowNumCTE
where row_num > 1
order by PropertyAddress

--want to partition data. we need to partition on things that should be unique 
--we want to identify duplicate rows. we use the row numbers
-- from the above query we see that there are 104 duplicates 

--To delete the duplicate rows. we use DELETE 
WITH RowNumCTE AS(
select *,
    ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by UniqueID
				) row_num
from PortfolioProject.dbo.NashvilleHousing
)
Delete 
from RowNumCTE
where row_num > 1

---------------------------------------------------------------------------------------------------------------------------------

--Delete Unused Columns

Alter table PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

Alter table PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate






