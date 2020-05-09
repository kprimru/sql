USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[DISTR_TYPE_UPDATE]
	@ID	INT,
	@NAME	VARCHAR(50),
	@ORDER	INT,
	@FULL	NVARCHAR(50),
	@CHECK	BIT,
	@Code	VarChar(100)
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

		UPDATE dbo.DistrTypeTable
		SET DistrTypeName = @NAME,
			DistrTypeOrder = @ORDER,
			DistrTypeFull = @FULL,
			DistrTypeCode = @Code,
			DistrTypeBaseCheck = @CHECK
		WHERE DistrTypeID = @ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[DISTR_TYPE_UPDATE] TO rl_distr_type_u;
GO