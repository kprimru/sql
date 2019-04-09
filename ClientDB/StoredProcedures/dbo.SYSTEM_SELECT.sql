USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SYSTEM_SELECT]
	@FILTER	VARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		SystemID, SystemShortName, SystemBaseName, SystemNumber, HostShort, a.HostID,
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
		) AS IBS_SIZE
	FROM 
		dbo.SystemTable a
		LEFT OUTER JOIN dbo.Hosts b ON a.HostID = b.HostID
	WHERE @FILTER IS NULL
		OR SystemShortName LIKE @FILTER
		OR SystemName LIKE @FILTER
		OR SystemFullName LIKE @FILTER
		OR SystemBaseName LIKE @FILTER
		OR CONVERT(VARCHAR(20), SystemNumber) LIKE @FILTER
	ORDER BY SystemOrder
END