USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[CLIENT_SYSTEM_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[CLIENT_SYSTEM_UPDATE]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[CLIENT_SYSTEM_UPDATE]
	@ID		INT,
	@CLIENT	INT,
	@SYSTEM	INT,
	@DISTR	INT,
	@COMP	TINYINT,
	@STYPE	INT,
	@DTYPE	INT,
	@STATUS	UNIQUEIDENTIFIER,
	@BEGIN	SMALLDATETIME,
	@END	SMALLDATETIME
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

		UPDATE dbo.ClientSystemsTable
		SET	SystemID		=	@SYSTEM,
			SystemDistrNumber	=	@DISTR,
			CompNumber		=	@COMP,
			SystemTypeID	=	@STYPE,
			DistrTypeID		=	@DTYPE,
			DistrStatusID	=	@STATUS
		WHERE ID = @ID


		DECLARE @BDATE SMALLDATETIME
		DECLARE @EDATE SMALLDATETIME

		SELECT TOP 1 @BDATE = SystemBegin, @EDATE = SystemEnd
		FROM dbo.ClientSystemDatesTable
		WHERE IDMaster = @ID
		ORDER BY SystemDate DESC

		IF
			(
				(@BDATE IS NOT NULL AND @BEGIN IS NOT NULL) AND
				(@BDATE <> @BEGIN)
			) OR
			(
				@BDATE IS NULL AND @BEGIN IS NOT NULL
			) OR
			(
				@BDATE IS NOT NULL AND @BEGIN IS NULL
			) OR
			(
				(@EDATE IS NOT NULL AND @END IS NOT NULL) AND
				(@EDATE <> @END)
			) OR
			(
				@EDATE IS NULL AND @END IS NOT NULL
			) OR
			(
				@EDATE IS NOT NULL AND @END IS NULL
			)
		BEGIN
			INSERT INTO dbo.ClientSystemDatesTable (IDMaster, SystemBegin, SystemEnd)
				VALUES(@ID, @BEGIN, @END)
		END

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[CLIENT_SYSTEM_UPDATE] TO rl_client_system_u;
GO
