/* 

Cleaning Data in SQL Queries 

*/

Select *
From NashvilleHousing

-- Standardize Date Format --  

--Method 1
Select SaleDate, CONVERT(Date,SaleDate)
From NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

--Method 2

ALTER Table NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDateConverted
From NashvilleHousing

-----------------------------------------------------------------

-- Populate Property Address data --

Select *
From NashvilleHousing
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,  b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

Update a 
SET PropertyAddress = ISNULL(a.PropertyAddress,  b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null


--- Breaking out Address into Individual Columns (Address, City, State)---

Select PropertyAddress
From NashvilleHousing 


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From NashvilleHousing 


ALTER Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 


ALTER Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) 

Select *
From NashvilleHousing


-- With PARSENAME--

Select OwnerAddress
From NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) 
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) 
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) 
From NashvilleHousing


ALTER Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) 

ALTER Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) 

ALTER Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) 

Select *
From NashvilleHousing


---- Change Y and N to Yes and No in "Sold as Vacant" field -----

Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN	SoldAsVacant = 'N' THEN 'No'	
	   ELSE SoldAsVacant
	   END
From NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN	SoldAsVacant = 'N' THEN 'No'	
	   ELSE SoldAsVacant
	   END

	   
-----------------------------------------------

-- Remove Duplicates -- 

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

From NashvilleHousing
)

DELETE
From RowNumCTE
Where row_num > 1 


------------------------------

----Delete Unused Columns----

Select *
From NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN TaxDistrict, LegalReference 