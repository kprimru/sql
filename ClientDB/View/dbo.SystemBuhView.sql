USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE VIEW [dbo].[SystemBuhView]
AS
	SELECT SystemID, SystemName, SystemPrefix, SystemOrder, SystemPostfix, SystemReg
	FROM [PC275-SQL\GAMMA].[BuhDB].dbo.SystemTable