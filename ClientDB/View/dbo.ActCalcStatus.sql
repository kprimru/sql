USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ActCalcStatus]', 'V ') IS NULL EXEC('CREATE VIEW [dbo].[ActCalcStatus]  AS SELECT 1')
GO
ALTER VIEW [dbo].[ActCalcStatus]
AS
	SELECT 1 AS ST, 'Заявка создана' AS ST_TEXT
GO
