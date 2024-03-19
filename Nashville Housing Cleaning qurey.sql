
--#Cleaning Nashville Housing Data
-- Name of database is PortfolioProject
------------------------------------------

Select *
From PortfolioProject..[Nashville Housing];

--Standardize Date Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject..[Nashville Housing];

Alter Table PortfolioProject..[Nashville Housing]
Add SaleDateConverted Date;

Update PortfolioProject..[Nashville Housing]
Set SaleDateConverted = CONVERT(Date, SaleDate);

-------------------------------------------------
--Populate Null Property Address Data

Select *
From PortfolioProject..[Nashville Housing]
--Where PropertyAddress is null
Order by ParcelID;

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..[Nashville Housing] a
Join PortfolioProject..[Nashville Housing] b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null;

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..[Nashville Housing] a
Join PortfolioProject..[Nashville Housing] b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null;

-------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City)

Select PropertyAddress
From PortfolioProject..[Nashville Housing];
--Where PropertyAddress is null
--Order by ParcelID

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 ) As Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) As City
From PortfolioProject..[Nashville Housing];

Alter Table PortfolioProject..[Nashville Housing]
Add PropertySplitAddress Nvarchar(255);

Alter Table PortfolioProject..[Nashville Housing]
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject..[Nashville Housing]
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 );

Update PortfolioProject..[Nashville Housing]
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));


-----
-- Using PARSENAME to split Address, City, State on Owner Address Column

Select OwnerAddress
From PortfolioProject..[Nashville Housing];

Select
PARSENAME(Replace(OwnerAddress,',','.'), 3) As Address
,PARSENAME(Replace(OwnerAddress,',','.'), 2) As City
,PARSENAME(Replace(OwnerAddress,',','.'), 1)As State
From PortfolioProject..[Nashville Housing];

Alter Table PortfolioProject..[Nashville Housing]
Add OwnerSplitAddress Nvarchar(255);

Alter Table PortfolioProject..[Nashville Housing]
Add OwnerSplitCity Nvarchar(255);

Alter Table PortfolioProject..[Nashville Housing]
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject..[Nashville Housing]
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'), 3);

Update PortfolioProject..[Nashville Housing]
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'), 2);

Update PortfolioProject..[Nashville Housing]
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'), 1);


-----------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..[Nashville Housing]
Group by SoldAsVacant
Order by 2;

Select SoldAsVacant
,Case 
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
End
From PortfolioProject..[Nashville Housing];

Update PortfolioProject..[Nashville Housing]
Set SoldAsVacant =
Case 
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
End;

---------------------------------------------

--Remeoving Duplicate

With RowNumCTE As(
Select *,
	ROW_NUMBER() Over (
	Partition BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By
					UniqueID
					) row_num

From PortfolioProject..[Nashville Housing]
)
Delete 
From RowNumCTE
Where row_num > 1;

--Select * 
--From RowNumCTE
--Where row_num > 1;

--------------------------------

-- Delete irrelevant Columns

Select *
From PortfolioProject..[Nashville Housing];

Alter Table PortfolioProject..[Nashville Housing]
Drop  Column OwnerAddress, TaxDistrict, PropertyAddress;
