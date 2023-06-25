USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Import].[Client@Parse]', 'IF') IS NULL EXEC('CREATE FUNCTION [Import].[Client@Parse] () RETURNS TABLE AS RETURN (SELECT [NULL] = NULL)')
GO
CREATE FUNCTION [Import].[Client@Parse]
(
	@Data Xml
)
RETURNS TABLE
AS
RETURN
(
	SELECT
		[Company_Id],
		[Personal],
		[Phone],
		[Inn]
	FROM
	(
		SELECT
			[Company_Id]	= Node.value('@Company_Id[1]',	'UniqueIdentifier'),
			[Personal]		= Node.value('@Personal[1]',	'Bit'),
			[Phone]			= Node.value('@Phone[1]',		'Bit'),
			[Inn]			= Node.value('@Inn[1]',			'Bit')
		FROM @Data.nodes('/root/item') Data(Node)
	) AS C
)GO
