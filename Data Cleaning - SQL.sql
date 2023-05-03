/*

Cleaning data in SQL queries 

*/

Use PortfolioProject




Select * 
From PortfolioProject.dbo.NashvilleHousing

---------------------------------------------------------

-- Stabdardize sale date

Select SaleDate, CONVERT(Date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update dbo.NashvilleHousing
Set SaleDate  = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update dbo.NashvilleHousing
Set SaleDateConverted  = CONVERT(Date, SaleDate)


Select SaleDateConverted 
From PortfolioProject.dbo.NashvilleHousing


---------------------------------------

--- Populate Property Address data

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


---------------------------------------------------------------

--- Breaking out address into individual columns (Address, City, State)


Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID


Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update dbo.NashvilleHousing
Set PropertySplitAddress  = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update dbo.NashvilleHousing
Set PropertySplitCity  = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


Select *
From PortfolioProject.dbo.NashvilleHousing


Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing
--where OwnerAddress is null


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update dbo.NashvilleHousing
Set OwnerSplitAddress  = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) 


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update dbo.NashvilleHousing
Set OwnerSplitCity  = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update dbo.NashvilleHousing
Set OwnerSplitState  = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select * 
From PortfolioProject.dbo.NashvilleHousing

------------------------------------------------------------------------------

-- Change Y and N to Yes and No in 'Sold As Vacant' field

Select DISTINCT(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing


Select SoldAsVacant
From PortfolioProject.dbo.NashvilleHousing
where SoldAsVacant = 'Y'

Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2



Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   ELSE SoldAsVacant
	   END

From PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   ELSE SoldAsVacant
	   END


----------------------------------------------------------------------------

-- Remove Duplicates


Select *, 
From PortfolioProject.dbo.NashvilleHousing





WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
			     PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num


From PortfolioProject.dbo.NashvilleHousing
)
Select *
From RowNumCTE
where row_num > 1
Order by PropertyAddress


-- Delete duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
			     PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num


From PortfolioProject.dbo.NashvilleHousing
)
DELETE
From RowNumCTE
where row_num > 1
--Order by PropertyAddress


----------------------------------------------------------------------------------

-- Remove Unused columns


Select *
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate