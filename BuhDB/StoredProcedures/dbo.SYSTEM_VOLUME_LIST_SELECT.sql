USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SYSTEM_VOLUME_LIST_SELECT]
	@DATA	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	IF @DATA IS NULL
		SELECT SystemID, SystemPrefix + ' ' + SystemName AS SystemFullName, SystemName, SystemVolume
		FROM
			dbo.SystemTable a
			INNER JOIN dbo.SystemGroupTable b ON a.SystemGroupID = b.SystemGroupID
		ORDER BY SystemGroupOrder, SystemOrder
	ELSE
	BEGIN
		DECLARE @xml XML

		SET @XML = CAST(@DATA AS XML)

		SELECT
			a.SystemID, SystemPrefix + ' ' + SystemName AS SystemFullName, SystemName, SystemVolume,
			VOLUME AS NewVolume
		FROM
			(
				SELECT
					c.value('@id',  'INT') AS ID,
					c.value('@volume', 'Int') AS VOLUME
				FROM @XML.nodes('/root/item') AS a(c)
			) AS t
			INNER JOIN dbo.SystemTable a ON a.SystemID = t.ID
			INNER JOIN dbo.SystemGroupTable b ON a.SystemGroupID = b.SystemGroupID
		ORDER BY SystemGroupOrder, SystemOrder
	END
END
GO
GRANT EXECUTE ON [dbo].[SYSTEM_VOLUME_LIST_SELECT] TO DBPrice;
GO
