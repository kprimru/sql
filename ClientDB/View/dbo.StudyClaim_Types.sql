USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[StudyClaim_Types]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[StudyClaim_Types]  AS SELECT 1')
GO
CREATE   VIEW [dbo].[StudyClaim_Types] AS
	SELECT [Name] = 'Новый клиент'
	UNION ALL
	SELECT [Name] = 'Замена дистрибутива'
	UNION ALL
	SELECT [Name] = 'Восстановление'
	UNION ALL
	SELECT [Name] = 'Новый дистрибутив'
GO
