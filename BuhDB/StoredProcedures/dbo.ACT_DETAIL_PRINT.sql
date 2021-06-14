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
	    SystemPrice, TaxPrice, SystemPrice + TaxPrice AS TotalPrice, SystemNote,
	    SystemExpire
	FROM ActSystemsTable WITH(NOLOCK)
	WHERE ActID = @ACT AND NOT (SystemName LIKE '%Yubikey%' OR SystemName LIKE '%פכ‎ר%')
	ORDER BY SystemOrder
END

GO
GRANT EXECUTE ON [dbo].[ACT_DETAIL_PRINT] TO DBCount;
GO