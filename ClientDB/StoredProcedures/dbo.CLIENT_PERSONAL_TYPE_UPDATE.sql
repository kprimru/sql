USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CLIENT_PERSONAL_TYPE_UPDATE]
	@ID			UNIQUEIDENTIFIER,
	@NAME		VARCHAR(100),
	@PSEDO		VARCHAR(50),
	@REQUIRED	BIT
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

		UPDATE dbo.ClientPersonalType
		SET CPT_NAME		=	@NAME,
			CPT_PSEDO		=	@PSEDO,
			CPT_REQUIRED	=	@REQUIRED
		WHERE CPT_ID		=	@ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_PERSONAL_TYPE_UPDATE] TO rl_client_personal_type_u;
GO
