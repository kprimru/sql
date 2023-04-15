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
		[CompanyName]	= Node.value('@CompanyName[1]',		'VarChar(256)'),
		[Inn]			= Node.value('@Inn[1]',				'VarChar(20)'),
		[Address]		= Node.value('@Address[1]',			'VarChar(256)'),
		[Surname]		= Node.value('@Surname[1]',			'VarChar(256)'),
		[Name]			= Node.value('@Name[1]',			'VarChar(256)'),
		[Patron]		= Node.value('@Patron[1]',			'VarChar(256)'),
		[Activity]		= Node.value('@Activity[1]',		'VarChar(256)'),
		[Phones]		= Node.value('@Phones[1]',			'VarChar(256)'),
		[Email]			= Node.value('@Email[1]', 			'VarChar(256)')
	FROM @Data.nodes('/IMPORT/ITEM') Data(Node)
)GO
