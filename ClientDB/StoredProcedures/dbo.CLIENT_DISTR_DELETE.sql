USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_DISTR_DELETE]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO dbo.ClientDistr(ID_CLIENT, ID_HOST, ID_SYSTEM, DISTR, COMP, ID_TYPE, ID_NET, ID_STATUS, ON_DATE, OFF_DATE, STATUS, BDATE, EDATE, UPD_USER)
		SELECT ID_CLIENT, ID_HOST, ID_SYSTEM, DISTR, COMP, ID_TYPE, ID_NET, ID_STATUS, ON_DATE, OFF_DATE, 2, BDATE, GETDATE(), UPD_USER
		FROM dbo.ClientDistr
		WHERE ID = @ID
	
	UPDATE dbo.ClientDistr
	SET STATUS = 3,
		EDATE = GETDATE(),
		UPD_USER = ORIGINAL_LOGIN()
	WHERE ID = @ID
END