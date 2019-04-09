USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_ERROR_SELECT]
	@CLIENT	INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ID, NOTE, UPD_DATE
	FROM dbo.ClientError
	WHERE ID_CLIENT = @CLIENT
		AND STATUS = 1
	ORDER BY UPD_DATE DESC
END
