USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_ERROR_REASON_TYPE]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT TP
	FROM dbo.ClientErrorReason
END
