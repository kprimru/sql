USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ClientFilterWrite]', 'FN') IS NULL EXEC('CREATE FUNCTION [dbo].[ClientFilterWrite] () RETURNS Int AS BEGIN RETURN NULL END')
GO
ALTER FUNCTION [dbo].[ClientFilterWrite]
(
	@SRC	NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @XML XML

	SET @XML = CAST(@SRC AS XML)

	DECLARE @RESULT NVARCHAR(MAX)
	SET @RESULT =
		(
			SELECT a.WCL_ID AS 'ITEM'
			FROM
				dbo.ClientWriteList() a
				INNER JOIN
					(
						SELECT c.value('(.)', 'INT') AS ID
						FROM @xml.nodes('/LIST/ITEM') AS a(c)
					) AS b ON a.WCL_ID = b.ID
			FOR XML PATH(''), ROOT('LIST')
		)

	RETURN @RESULT
END
GO
