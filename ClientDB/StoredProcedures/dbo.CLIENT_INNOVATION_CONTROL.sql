USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_INNOVATION_CONTROL]
	@PERSONAL	UNIQUEIDENTIFIER,
	@DATE		SMALLDATETIME,
	@SURNAME	NVARCHAR(256),
	@NAME		NVARCHAR(256),
	@PATRON		NVARCHAR(256),
	@NOTE		NVARCHAR(MAX),
	@RESULT		TINYINT
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

		UPDATE dbo.ClientInnovationControl
		SET DATE	=	@DATE,
			AUDITOR	=	ORIGINAL_LOGIN(),
			SURNAME	=	@SURNAME,
			NAME	=	@NAME,
			PATRON	=	@PATRON,
			NOTE	=	@NOTE,
			RESULT	=	@RESULT
		WHERE ID_PERSONAL = @PERSONAL

		IF @@ROWCOUNT = 0
			INSERT INTO dbo.ClientInnovationControl(ID_PERSONAL, DATE, SURNAME, NAME, PATRON, NOTE, RESULT)
				VALUES(@PERSONAL, @DATE, @SURNAME, @NAME, @PATRON, @NOTE, @RESULT)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_INNOVATION_CONTROL] TO rl_client_innovation_control;
GO
