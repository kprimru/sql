USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Memo].[KGS_CLIENT_DISTR_SELECT]
	@LIST	NVARCHAR(MAX),
	@STATUS	BIT = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @XML XML

	SET @XML = CAST(@LIST AS XML)
	
	SELECT 
		b.ID_CLIENT, b.SystemID, b.SystemShortName, b.SystemOrder, 
		DISTR, COMP, dbo.DistrString(NULL, DISTR, COMP) AS DISTR_STR,
		c.DistrTypeID, c.DistrTypeName, c.DistrTypeOrder, 
		SystemTypeID, SystemTypeName
	FROM
		(
			SELECT
				c.value('(.)', 'INT') AS CL_ID
			FROM @xml.nodes('/LIST/ITEM') AS a(c)
		) AS a
		INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON b.ID_CLIENT = a.CL_ID
		INNER JOIN dbo.DistrTypeTable c ON c.DistrTypeID = b.DistrTypeID
	WHERE (DS_REG = 0 AND @STATUS = 1 OR @STATUS = 0 AND DS_REG IN (0, 1))
END
