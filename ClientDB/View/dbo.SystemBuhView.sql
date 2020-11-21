USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER VIEW [dbo].[SystemBuhView]
AS
	SELECT SystemID, SystemName, SystemPrefix, SystemOrder, SystemPostfix, SystemReg
	FROM [BuhDB].[dbo.SystemTable]
GO
