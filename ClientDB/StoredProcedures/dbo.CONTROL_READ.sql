USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CONTROL_READ]
	@CC_ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	IF (SELECT Maintenance.GlobalControlLogin()) = '0'
	BEGIN
		UPDATE dbo.ClientControl
		SET CC_READER = ORIGINAL_LOGIN(),
			CC_READ_DATE = GETDATE()
		WHERE CC_ID = @CC_ID
	END
END