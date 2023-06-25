USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Import].[Client@Parse Client]', 'IF') IS NULL EXEC('CREATE FUNCTION [Import].[Client@Parse Client] () RETURNS TABLE AS RETURN (SELECT [NULL] = NULL)')
GO
CREATE FUNCTION [Import].[Client@Parse Client]
(
	@Data Xml
)
RETURNS TABLE
AS
RETURN
(
	SELECT
		[CompanyName],
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
			[CompanyName]	= Node.value('@CompanyName[1]',		'VarChar(256)'),
			[LegalForm]		= Node.value('@LegalForm[1]',		'VarChar(32)'),
			[Inn]			= Node.value('@Inn[1]',				'VarChar(20)'),
			[Address]		= Node.value('@Address[1]',			'VarChar(256)'),
			[Surname]		= Node.value('@Surname[1]',			'VarChar(256)'),
			[Name]			= Node.value('@Name[1]',			'VarChar(256)'),
			[Patron]		= Node.value('@Patron[1]',			'VarChar(256)'),
			[Activity]		= Node.value('@Activity[1]',		'VarChar(256)'),
			[Phones]		= Node.value('@Phones[1]',			'VarChar(256)'),
			[Email]			= Node.value('@Email[1]', 			'VarChar(256)')
		FROM @Data.nodes('/root/item') Data(Node)
	) AS C
)
GO
