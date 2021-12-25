USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [Client].[CompanyFilterWrite]
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
