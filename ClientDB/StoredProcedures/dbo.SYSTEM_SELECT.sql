USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SYSTEM_SELECT]
	@FILTER			VARCHAR(100) = NULL,
	@SYSTEM_ACTIVE	BIT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		a.SystemID, SystemShortName, a.SystemBaseName, SystemNumber, HostShort, a.HostID,
		dbo.FileByteSizeToStr(
			(
				SELECT SUM(IBS_SIZE)
				FROM 
					dbo.InfoBankSizeView y WITH(NOEXPAND)
					INNER JOIN dbo.SystemBankTable z ON z.InfoBankID = IBF_ID_IB
				WHERE z.SystemID = a.SystemID
					AND IBS_DATE = 
						(
							SELECT MAX(IBS_DATE)
							FROM dbo.InfoBankSizeView t WITH(NOEXPAND)
							WHERE t.IBF_ID_IB = y.IBF_ID_IB							
						)
			)
		) AS IBS_SIZE,
		sdv.Docs
	FROM 
		dbo.SystemTable a
		LEFT OUTER JOIN dbo.Hosts b ON a.HostID = b.HostID
		LEFT OUTER JOIN dbo.SystemDocsView sdv ON a.SystemID = sdv.SystemID
	WHERE (@FILTER IS NULL
		OR SystemShortName LIKE @FILTER
		OR SystemName LIKE @FILTER
		OR SystemFullName LIKE @FILTER
		OR a.SystemBaseName LIKE @FILTER
		OR CONVERT(VARCHAR(20), SystemNumber) LIKE @FILTER) AND
		(@SYSTEM_ACTIVE IS NULL
		OR SystemActive = @SYSTEM_ACTIVE)
	ORDER BY SystemOrder
END
