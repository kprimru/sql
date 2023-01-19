USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Client].[CompanyFilterWrite]', 'FN') IS NULL EXEC('CREATE FUNCTION [Client].[CompanyFilterWrite] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE FUNCTION [Client].[CompanyFilterWrite]
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
			SELECT a.ID AS 'item/@id'
			FROM
				Client.CompanyWriteList() a
				INNER JOIN
					(
						SELECT c.value('(@id)', 'UNIQUEIDENTIFIER') AS ID
						FROM @xml.nodes('/root/item') AS a(c)
					) AS b ON a.ID = b.ID
			FOR XML PATH('root')
		)

	RETURN @RESULT
END
GO
