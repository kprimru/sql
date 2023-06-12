USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Client].[ImportList@Parse]', 'IF') IS NULL EXEC('CREATE FUNCTION [Client].[ImportList@Parse] () RETURNS TABLE AS RETURN (SELECT [NULL] = NULL)')
GO
CREATE FUNCTION [Client].[ImportList@Parse]
(
	@Data Xml
)
RETURNS TABLE
AS
RETURN
(
	SELECT
		[CompanyName]	= CRC.[CompnyWithoutRightQoute],
		[LegalForm],
		[Inn],
		[Address],
		[Surname],
		[Name],
		[Patron],
		[Activity],
		[Phones],
		[Email]
	FROM
	(
		SELECT
			[Company]		= Node.value('@CompanyName[1]',		'VarChar(256)'),
			[LegalForm]		= Node.value('@LegalForm[1]',		'VarChar(32)'),
			[Inn]			= Node.value('@Inn[1]',				'VarChar(20)'),
			[Address]		= Node.value('@Address[1]',			'VarChar(256)'),
			[Surname]		= Node.value('@Surname[1]',			'VarChar(256)'),
			[Name]			= Node.value('@Name[1]',			'VarChar(256)'),
			[Patron]		= Node.value('@Patron[1]',			'VarChar(256)'),
			[Activity]		= Node.value('@Activity[1]',		'VarChar(256)'),
			[Phones]		= Node.value('@Phones[1]',			'VarChar(256)'),
			[Email]			= Node.value('@Email[1]', 			'VarChar(256)')
		FROM @Data.nodes('/IMPORT/ITEM') Data(Node)
	) AS C
	OUTER APPLY
	(
		SELECT [HasLeftQuote] = CASE WHEN CharIndex('"', [Company]) = 0 THEN 0 ELSE 1 END
	) AS HLC
	OUTER APPLY
	(
		SELECT
			[CompnyWithoutLeftQoute]  =
				CASE
					WHEN [HasLeftQuote] = 0 THEN [Company]
					ELSE Right([Company], Len([Company]) - CharIndex('"', [Company]))
				END
	) AS CLC
	OUTER APPLY
	(
		SELECT [HasRightQuote] = CASE WHEN CharIndex('"', [CompnyWithoutLeftQoute]) = 0 THEN 0 ELSE 1 END
	) AS HRC
	OUTER APPLY
	(
		SELECT
			[CompnyWithoutRightQoute]  =
				CASE
					WHEN [HasRightQuote] = 0 THEN [CompnyWithoutLeftQoute]
					ELSE Left([CompnyWithoutLeftQoute], Len([CompnyWithoutLeftQoute]) - CharIndex('"', Reverse([CompnyWithoutLeftQoute])))
				END
	) AS CRC
)GO
