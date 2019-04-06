USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[HOTLINE_DISTR_LIST]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @L NVARCHAR(MAX)
	SET @L = ''

	SET @L = 
		(
			SELECT
				CONVERT(VARCHAR(20), d.SystemNumber) + '_' + 
				--CONVERT(VARCHAR(20), c.SystemNumber) + '_' + 
				REPLICATE('0', 6 - LEN(CONVERT(VARCHAR(20), DistrNumber))) + CONVERT(VARCHAR(20), DistrNumber) + 
				CASE CompNumber WHEN 1 THEN '' ELSE '_' + REPLICATE('0', 2 - LEN(CONVERT(VARCHAR(20), CompNumber))) + CONVERT(VARCHAR(20), CompNumber) END + ', '
			FROM 
				dbo.RegNodeCurrentView a WITH(NOEXPAND)
				INNER JOIN
				(
					SELECT DISTINCT ID_HOST, DISTR, COMP
					FROM dbo.HotlineDistr
					WHERE STATUS = 1
				) AS b ON a.HostID = ID_HOST AND DistrNumber = DISTR AND CompNumber = COMP
				INNER JOIN dbo.SystemTable c ON c.SystemID = a.SystemID
				INNER JOIN dbo.SystemTable d ON d.HostID = a.HostID 
			ORDER BY a.SystemOrder, DistrNumber, CompNumber FOR XML PATH('')
		)
	
	
	IF @L <> ''
		SET @L = LEFT(RTRIM(@L), LEN(@L) - 1)
		
	SELECT @L AS LIST
END

