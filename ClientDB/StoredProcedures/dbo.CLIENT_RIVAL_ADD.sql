USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_RIVAL_ADD]
	@CL_ID	INT,
	@DATE	SMALLDATETIME,
	@TYPE	INT,
	@STATUS	INT,
	@CONDITION	VARCHAR(MAX),
	@PERSONAL	VARCHAR(MAX),
	@SURNAME	NVARCHAR(256) = NULL,
	@NAME		NVARCHAR(256) = NULL,
	@PATRON		NVARCHAR(256) = NULL,
	@PHONE		NVARCHAR(256) = NULL
WITH EXECUTE AS OWNER
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

		DECLARE @ID INT

		INSERT INTO dbo.ClientRival(
				CL_ID, CR_DATE, CR_ID_TYPE, CR_ID_STATUS, CR_COMPLETE, CR_CONTROL, CR_CONDITION,
				CR_SURNAME, CR_NAME, CR_PATRON, CR_PHONE
				)
			VALUES(@CL_ID, @DATE, @TYPE, @STATUS, 0, 0, @CONDITION, @SURNAME, @NAME, @PATRON, @PHONE)

		SELECT @ID = SCOPE_IDENTITY()

		UPDATE dbo.ClientRival
		SET CR_ID_MASTER = @ID
		WHERE CR_ID = @ID

		EXEC dbo.CLIENT_RIVAL_PERSONAL_SET_NEW @ID, @PERSONAL

		DECLARE RV CURSOR LOCAL FOR
			SELECT a.name
			FROM
				sys.database_principals a
				INNER JOIN sys.database_role_members b ON a.principal_id = member_principal_id
				INNER JOIN sys.database_principals c ON c.principal_id = role_principal_id
			WHERE c.name = 'rl_client_rival_message'

		OPEN RV

		DECLARE @RECEIVE_USER NVARCHAR(128)

		FETCH NEXT FROM RV INTO @RECEIVE_USER

		WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC dbo.CLIENT_MESSAGE_SEND @CL_ID, 1, @RECEIVE_USER, @CONDITION, 0

			FETCH NEXT FROM RV INTO @RECEIVE_USER
		END

		CLOSE RV
		DEALLOCATE RV

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_RIVAL_ADD] TO rl_client_rival_i;
GO