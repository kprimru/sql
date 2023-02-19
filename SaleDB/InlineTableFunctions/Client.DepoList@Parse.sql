﻿USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Client].[DepoList@Parse]', 'IF') IS NULL EXEC('CREATE FUNCTION [Client].[DepoList@Parse] () RETURNS TABLE AS RETURN (SELECT [NULL] = NULL)')
GO
CREATE FUNCTION [Client].[DepoList@Parse]
(
	@Data Xml
)
RETURNS TABLE
AS
RETURN
(
	SELECT
		[Ric]				= Node.value('@Ric[1]',					'SmallInt'),
		[Code]				= Node.value('@Code[1]',				'Int'),
		[Priority]			= Node.value('@Priority[1]',			'Int'),
		[Name]				= Node.value('@Name[1]',				'VarChar(256)'),
		[Inn]				= Node.value('@Inn[1]',					'VarChar(20)'),
		[RegionAndAddress]	= Node.value('@RegionAndAddress[1]',	'VarChar(256)'),
		[Person1FIO]		= Node.value('@Person1FIO[1]',			'VarChar(128)'),
		[Person1Phone]		= Node.value('@Person1Phone[1]',		'VarChar(128)'),
		[Result]			= Node.value('@Result[1]', 				'VarChar(50)'),
		[Status]			= Node.value('@Status[1]', 				'VarChar(50)'),
		[AlienInn]			= Node.value('@AlienInn[1]', 			'VarChar(50)'),
		[DepoDate]			= Convert(SmallDateTime, Node.value('@DepoDate[1]', 			'VarChar(100)'), 3),
		[DepoExpireDate]	= Convert(SmallDateTime, Node.value('@DepoExpireDate[1]',		'VarChar(100)'), 3),
		[SerialADate]		= Convert(SmallDateTime, Node.value('@SerialADate[1]',			'VarChar(100)'), 3),
		[Rival]				= Node.value('@Rival[1]',				'VarChar(50)')
	FROM @Data.nodes('/DEPO/ITEM') Data(Node)
)
GO
