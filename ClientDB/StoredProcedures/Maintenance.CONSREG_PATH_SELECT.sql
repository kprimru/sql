USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Maintenance].[CONSREG_PATH_SELECT]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT Maintenance.GlobalConsregPath() AS CONSREG_PATH
END
