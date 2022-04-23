USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ACT_DETAIL_PRINT]
	@ACT INT
AS
BEGIN
	SET NOCOUNT ON;

    SELECT
        SystemSet, SystemPrefix, SystemName, DistrTypeName, DistrNumber, NetVersion, DocCount,
        SystemPrice, TaxPrice, TotalPrice, SystemNote,
        SystemExpire, --IsGenerated
        IsGenerated = Cast(CASE WHEN IsGenerated IS NOT NULL AND IsGenerated != 1 THEN 0  ELSE IsGenerated END AS Bit)
    FROM
    (
	    SELECT
	        SystemSet, SystemPrefix, SystemName, DistrTypeName, DistrNumber, NetVersion, DocCount,
	        SystemPrice, TaxPrice, SystemPrice + TaxPrice AS TotalPrice, SystemNote, SystemOrder,
	        SystemExpire, --IsGenerated
	        IsGenerated = CASE WHEN SystemPrice = 60 THEN Row_Number() OVER(PARTITION BY SystemName, DistrNumber, SystemPrice ORDER BY SystemOrder) ELSE 0 END
	    FROM ActSystemsTable WITH(NOLOCK)
	    WHERE ActID = @ACT AND NOT (SystemName LIKE '%Yubikey%' OR SystemName LIKE '%флэш%')
	) AS o_O
	ORDER BY SystemOrder, DistrNumber, SystemPrice
END
GO
GRANT EXECUTE ON [dbo].[ACT_DETAIL_PRINT] TO DBCount;
GO
