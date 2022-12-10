USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/*
Автор:		  Проценко Сергей
Описание:
*/

ALTER PROCEDURE [dbo].[SUBHOST_TYPE_ADD]
	--@subhostId		int,
	@subhostCode	VarChar (50),
	@subhostName	VarChar (100),
	@subhostActive	BIT = 1,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		INSERT INTO [dbo].[SubhostType](ST_CODE, ST_NAME, ST_ACTIVE) --ST_ID,
		VALUES (@subhostCode, @subhostName,	@subhostActive) --@subhostId,

		IF @returnvalue = 1
			SELECT SCOPE_IDENTITY() AS NEW_IDEN

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SUBHOST_TYPE_ADD] TO rl_subhost_type_w;
GO
