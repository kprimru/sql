USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SystemBuhView]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[SystemBuhView]  AS SELECT 1')
GO
ALTER VIEW [dbo].[SystemBuhView]
AS
	SELECT SystemID, SystemName, SystemPrefix, SystemOrder, SystemPostfix, SystemReg
	FROM [PC275-SQL\GAMMA].[BuhDB].dbo.SystemTable
GO
