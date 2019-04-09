USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reg].[REG_LIST_CHECK]
	@LST	NVARCHAR(MAX),
	@STATUS	BIT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @XML XML
	
	SET @XML = CAST(@LST AS XML)

	SELECT 
		(
			SELECT '������ ��������� ����������� ' + DistrStr + CHAR(10) + CHAR(13) AS ERR_TXT
			FROM
				(
					SELECT
						c.value('(@hostid)', 'INT') AS HostID, 
						c.value('(@distr)', 'INT') AS DISTR, 
						c.value('(@comp)', 'TINYINT') AS COMP 
					FROM @xml.nodes('/root/item') AS a(c)			
				) AS a
				LEFT OUTER JOIN Reg.RegNodeSearchView b WITH(NOEXPAND) ON a.HostID = b.HostID AND a.DISTR = b.DistrNumber AND a.COMP = b.CompNumber
				LEFT OUTER JOIN dbo.SystemTable c ON b.SystemID = c.SystemID
			WHERE b.DS_REG IS NULL OR b.DS_REG = 0 AND @STATUS = 0 OR b.DS_REG = 1 AND @STATUS = 1 
			FOR XML PATH('')
		) AS ERR_TXT
END
