USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[DBFTODistrView]
AS	
	SELECT DIS_NUM, TD_ID_TO
	FROM [PC275-SQL\DELTA].DBF.dbo.TODistrView