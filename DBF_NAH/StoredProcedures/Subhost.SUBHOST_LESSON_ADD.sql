﻿USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Subhost].[SUBHOST_LESSON_ADD]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Subhost].[SUBHOST_LESSON_ADD]  AS SELECT 1')
GO
ALTER PROCEDURE [Subhost].[SUBHOST_LESSON_ADD]
	@LS_NAME	VARCHAR(50),
	@LS_ORDER	SMALLINT,
	@ACTIVE	BIT,
	@return	BIT = 1
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

		INSERT INTO Subhost.Lesson(LS_NAME, LS_ORDER, LS_ACTIVE)
			VALUES(@LS_NAME, @LS_ORDER, @ACTIVE)

		IF @RETURN = 1
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
GRANT EXECUTE ON [Subhost].[SUBHOST_LESSON_ADD] TO rl_subhost_lesson_w;
GO
