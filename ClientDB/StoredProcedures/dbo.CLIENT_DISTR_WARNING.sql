USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_DISTR_WARNING]
	@CLIENT		INT,
	@WARN_COUNT	INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	
	SET @WARN_COUNT = 
		(
			SELECT COUNT(*)
			FROM 
				dbo.ClientDistrWarningView
				INNER JOIN dbo.ClientDistrWriteList() ON WCL_ID = ClientID
			WHERE ClientID = @CLIENT
		)
END