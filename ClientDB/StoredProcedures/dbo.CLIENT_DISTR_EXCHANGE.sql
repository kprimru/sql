USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[CLIENT_DISTR_EXCHANGE]
	@ID		UNIQUEIDENTIFIER,
	@SYSTEM	INT,
	@NET	INT,
	@DATE	SMALLDATETIME = NULL
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO dbo.ClientDistr(ID_CLIENT, ID_HOST, ID_SYSTEM, DISTR, COMP, ID_TYPE, ID_NET, ID_STATUS, ON_DATE, OFF_DATE, STATUS, BDATE, EDATE, UPD_USER)
		SELECT ID_CLIENT, ID_HOST, ID_SYSTEM, DISTR, COMP, ID_TYPE, ID_NET, ID_STATUS, ON_DATE, OFF_DATE, 2, BDATE, GETDATE(), UPD_USER
		FROM dbo.ClientDistr
		WHERE ID = @ID
		
	UPDATE dbo.ClientDistr
	SET ID_SYSTEM	= ISNULL(@SYSTEM, ID_SYSTEM),
		ID_NET		= ISNULL(@NET, ID_NET),
		ON_DATE		= @DATE,
		BDATE		= GETDATE(),
		UPD_USER	= ORIGINAL_LOGIN()		
	WHERE ID = @ID
END