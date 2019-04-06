USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_CONTRACT_REGISTER_SELECT]
	@ID	INT
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ID, VEN_NAME, DATE, CONVERT(NVARCHAR(32), YEAR) + '-' + NUM_STR AS NUM_STR, TP_NAME, NOTE, CLIENT
	FROM dbo.ContractRegisterView
	WHERE CLIENTID = @ID
	ORDER BY DATE DESC, NUM DESC
END
