﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ACTIVITY_UPDATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[ACTIVITY_UPDATE]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[ACTIVITY_UPDATE]
	@ID		UNIQUEIDENTIFIER,
	@NAME	VARCHAR(500),
	@CODE	VARCHAR(20),
	@SHORT	VARCHAR(100)
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

		UPDATE	dbo.Activity
		SET		AC_NAME		=	@NAME,
				AC_CODE		=	@CODE,
				AC_SHORT	=	@SHORT
		WHERE	AC_ID		=	@ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[ACTIVITY_UPDATE] TO rl_activity_u;
GO
