USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_DISTR_DISCONNECT]
	@ID		UNIQUEIDENTIFIER,
	@DATE	SMALLDATETIME
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DECLARE @STATUS UNIQUEIDENTIFIER

		SELECT @STATUS = DS_ID
		FROM dbo.DistrStatus
		WHERE DS_REG = 0

		DECLARE @STATUS_OFF UNIQUEIDENTIFIER

		IF EXISTS
			(
				SELECT *
				FROM
					Reg.RegNodeSearchView a WITH(NOEXPAND)
					INNER JOIN dbo.ClientDistrView b WITH(NOEXPAND) ON a.SystemID = b.SystemID
																	AND a.DistrNumber = b.DISTR
																	AND a.CompNumber = b.COMP
				WHERE b.ID = @ID AND a.DS_REG = 2
			)
			SELECT @STATUS_OFF = DS_ID
			FROM dbo.DistrStatus
			WHERE DS_REG = 2
		ELSE
			SELECT @STATUS_OFF = DS_ID
			FROM dbo.DistrStatus
			WHERE DS_REG = 1

		IF (SELECT ID_STATUS FROM dbo.ClientDistr WHERE ID = @ID) <> @STATUS
		BEGIN
			RAISERROR('Дистрибутив уже отключен от сопровождения. Операция отменена', 16, 1)
			RETURN
		END

		INSERT INTO dbo.ClientDistr(ID_CLIENT, ID_HOST, ID_SYSTEM, DISTR, COMP, ID_TYPE, ID_NET, ID_STATUS, ON_DATE, OFF_DATE, STATUS, BDATE, EDATE, UPD_USER)
			SELECT ID_CLIENT, ID_HOST, ID_SYSTEM, DISTR, COMP, ID_TYPE, ID_NET, ID_STATUS, ON_DATE, OFF_DATE, 2, BDATE, GETDATE(), UPD_USER
			FROM dbo.ClientDistr
			WHERE ID = @ID

		UPDATE dbo.ClientDistr
		SET ID_STATUS	= @STATUS_OFF,
			OFF_DATE	= @DATE,
			BDATE		= GETDATE(),
			UPD_USER	= ORIGINAL_LOGIN()
		WHERE ID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GRANT EXECUTE ON [dbo].[CLIENT_DISTR_DISCONNECT] TO rl_client_distr_disconnect;
GO