--Cleaning Data in SQL queries

--Standardized date format

SELECT SaleDateConverted
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT (date,SaleDate)

--Populate property address data where propertyaddress is null

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress ,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

--Breaking out Adress into Individual Columns (Address,City,State)
--USING SUBSTRING

SELECT SUBSTRING(PropertyAddress ,1,CHARINDEX(',',PropertyAddress)-1) as address,
SUBSTRING (PropertyAddress ,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as state
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAdress nvarchar (255);

update PortfolioProject.dbo.NashvilleHousing
set PropertySplitAdress = SUBSTRING(PropertyAddress ,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitState nvarchar (255);

update PortfolioProject.dbo.NashvilleHousing
set PropertySplitState  = SUBSTRING (PropertyAddress ,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT*
FROM PortfolioProject.dbo.NashvilleHousing

--USING PARSE

SELECT PARSENAME( REPLACE(OwnerAddress,',','.'),3),
PARSENAME( REPLACE(OwnerAddress,',','.'),2),
 PARSENAME( REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject.dbo.NashvilleHousing 
 
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress nvarchar (255);

update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitAddress  = PARSENAME( REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity nvarchar (255);

update PortfolioProject.dbo.NashvilleHousing
set  OwnerSplitCity   = PARSENAME( REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState nvarchar (255);

update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitState  = PARSENAME( REPLACE(OwnerAddress,',','.'),1)

--Change Y and N to Yes and No in 'SoldAsVacant' filed

SELECT DISTINCT (SoldAsVacant),COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE 
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant =CASE 
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END

--Removing Duplicates using CTE
WITH RowNumCTE AS(
SELECT*,
ROW_NUMBER()OVER(
PARTITION BY ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
ORDER BY UniqueID) row_num

FROM PortfolioProject.dbo.NashvilleHousing
)

DELETE
from RowNumCTE
where row_num>1

--Delete unused Coloumns

SELECT*
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress,SaleDate


