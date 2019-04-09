USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Memo].[KGS_CLIENT_SELECT]
	@LIST	NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @XML XML

	SET @XML = CAST(@LIST AS XML)
	
	SELECT ClientID, ClientFullName, CA_STR, CA_FULL
	FROM
		(
			SELECT
				c.value('(.)', 'INT') AS CL_ID
			FROM @xml.nodes('/LIST/ITEM') AS a(c)
		) AS a
		INNER JOIN dbo.ClientTable b ON a.CL_ID = b.ClientID
		INNER JOIN dbo.ClientAddressView c ON c.CA_ID_CLIENT = b.ClientID
END
