USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Tender].[SYSTEM_TYPES]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ID, NAME
	FROM Tender.SystemType
END
