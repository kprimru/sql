﻿USE [BuhDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SYSTEM_VOLUME_SET]
	@DATA	NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @xml XML

	SET @XML = CAST(@DATA AS XML)

	UPDATE a
	SET SystemVolume = VOLUME
	FROM
		dbo.SystemTable a
		INNER JOIN
			(
				SELECT
					c.value('@id', 'INT') AS ID,
					c.value('@volume', 'INT') AS VOLUME
				FROM @XML.nodes('/root/item') AS a(c)
			) AS t ON a.SystemID = t.ID

	SELECT 1
END
GO
GRANT EXECUTE ON [dbo].[SYSTEM_VOLUME_SET] TO DBPrice;
GO
