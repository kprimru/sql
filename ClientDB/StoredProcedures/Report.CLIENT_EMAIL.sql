USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[CLIENT_EMAIL]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    SELECT
		rnccv.ClientName AS [�������� �������], rnccv.ManagerName [������������], rnccv.ServiceName AS [��], 
		rnccv.NT_SHORT AS [����], rnccv.DistrStr AS [�����������], SST_SHORT AS [��� �������], rnccv.Complect AS [��������], ct.ClientEmail AS [E-Mail],
		CASE 
			WHEN ct.ClientEmail = '' OR ct.ClientEmail IS NULL THEN
				CONVERT(BIT, 0)
			WHEN ct.ClientEmail <> '' AND ct.ClientEmail IS NOT NULL THEN
				CONVERT(BIT, 1)
		END AS [������� E-Mail]
	FROM
		dbo.RegNodeComplectClientView rnccv 
		INNER JOIN dbo.ClientTable ct ON ct.ClientID = rnccv.ClientID
	WHERE DS_REG = 0
	ORDER BY ClientName, Complect, DistrStr, NT_SHORT
END
