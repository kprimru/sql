USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Control].[AUTHOR_SELECT]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT AUTHOR AS US_NAME
	FROM Control.ClientControl	
END
