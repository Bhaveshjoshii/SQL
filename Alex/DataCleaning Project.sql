Create database DataCleaning

use  DataCleaning

Select*
from [DataCleaning].[dbo].[Sheet1$]

--Stanardize Date Format

Select Saledate, CONVERT(date,saledate)
from [DataCleaning].[dbo].[Sheet1$]

update [DataCleaning].[dbo].[Sheet1$]
SET saledate = Convert (date,saledate) 


Alter Table [DataCleaning].[dbo].[Sheet1$]
ADD salesdateconverted date;

update [DataCleaning].[dbo].[Sheet1$]
set salesdateconverted = Convert (date,saledate) 

Select salesdateconverted, CONVERT(date,saledate)
from [DataCleaning].[dbo].[Sheet1$]



-- Populate Property Address Data 

Select *
from [DataCleaning].[dbo].[Sheet1$]
--where propertyaddress is null
order by parcelid


Select a.parcelid, a.propertyaddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
from [DataCleaning].[dbo].[Sheet1$] a
join [DataCleaning].[dbo].[Sheet1$] b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID]
Where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.propertyaddress, b.PropertyAddress)
from [DataCleaning].[dbo].[Sheet1$] a
join [DataCleaning].[dbo].[Sheet1$] b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID]
where a.propertyaddress is null



-- Breaking out Address into Individual Columns (address, city, State)


Select PropertyAddress
from [DataCleaning].[dbo].[Sheet1$]
--Where PropertyAddress is null
--order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 ,LEN(PropertyAddress)) as Address
from [DataCleaning].[dbo].[Sheet1$]


Alter Table [DataCleaning].[dbo].[Sheet1$]
ADD PropertySplitAddress Nvarchar(255);

update [DataCleaning].[dbo].[Sheet1$]
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


Alter Table [DataCleaning].[dbo].[Sheet1$]
ADD PropertySplitCitydate Nvarchar(255);

update [DataCleaning].[dbo].[Sheet1$]
set PropertySplitCitydate = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 ,LEN(PropertyAddress))



Select *
from [DataCleaning].[dbo].[Sheet1$]



Select OwnerAddress
from [DataCleaning].[dbo].[Sheet1$]

Select 
PARSENAME (Replace (OwnerAddress,',','.'),3)
,PARSENAME (Replace (OwnerAddress,',','.'),2)
,PARSENAME (Replace (OwnerAddress,',','.'),1)
From [DataCleaning].[dbo].[Sheet1$]



Alter Table [DataCleaning].[dbo].[Sheet1$]
ADD OwnerSplitAddress Nvarchar(255);

update [DataCleaning].[dbo].[Sheet1$]
set OwnerSplitAddress = PARSENAME (Replace (OwnerAddress,',','.'),3)


Alter Table [DataCleaning].[dbo].[Sheet1$]
ADD OwnerSplitCity Nvarchar(255);

update [DataCleaning].[dbo].[Sheet1$]
set OwnerSplitCity= PARSENAME (Replace (OwnerAddress,',','.'),2)

Alter Table [DataCleaning].[dbo].[Sheet1$]
ADD OwnerSplitState Nvarchar(255);

update [DataCleaning].[dbo].[Sheet1$]
set OwnerSplitState = PARSENAME (Replace (OwnerAddress,',','.'),1)


Select *
from [DataCleaning].[dbo].[Sheet1$]



--Change Y and N to Yes and No in "Sold as Vacant" Field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from [DataCleaning].[dbo].[Sheet1$]
Group by SoldAsVacant
Order by 2


Select SoldAsVacant
,Case When SoldAsVacant = 'Y' Then 'Yes'
	  When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant 
	End
from [DataCleaning].[dbo].[Sheet1$]


Update [DataCleaning].[dbo].[Sheet1$]
SET SoldAsVacant = CASE When SOldAsVacant ='Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant 
	END



-- Remove Duplicates
WITH RowNumCTE AS(
Select *,
ROW_NUMBER() Over (
Partition by ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER By 
			 UniqueID 
			 ) row_num

from [DataCleaning].[dbo].[Sheet1$]
--ORDER BY ParcelID
)
Select *
From RowNumCTE
Where row_num>1
order by PropertyAddress




Select *
from [DataCleaning].[dbo].[Sheet1$]

-- Delete unsued Columns

Select * 
From [DataCleaning].[dbo].[Sheet1$]

Alter Table [DataCleaning].[dbo].[Sheet1$]
Drop COlumn OwnerAddress, Taxdistrict, Propertyaddress

Alter Table [DataCleaning].[dbo].[Sheet1$]
Drop COlumn Saledate
